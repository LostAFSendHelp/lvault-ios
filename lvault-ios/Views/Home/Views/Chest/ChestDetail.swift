//
//  ChestDetail.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/18/24.
//

import SwiftUI
import PhotosUI
import Combine

struct ChestDetail: View {
    let transferrableChests: [Chest]
    @State private var showCreateTransactionSheet = false
    @State private var editingTransaction: Transaction?
    @State private var editingTransactionNote: Transaction?
    @State private var isReconcilingBalance: Bool = false
    @State private var transactionAscendingByDate: Bool = false
    @State private var searchText: String = ""
    @State private var showImagePicker = false
    @State private var showCameraPicker = false
    @State private var showImageSourceSelection = false
    @State private var showCameraPermissionView = false
    @State private var selectedImages: [PhotosPickerItem] = []
    @State private var ocrResults: [OCRResult] = []
    @State private var isProcessingOCR: Bool = false
    @State private var showTransactionSuggestionSheet: Bool = false
    @State private var cancellables = Set<AnyCancellable>()
    @State private var isCreatingTransactionsBySuggestions: Bool = false
    @State private var alertError: Error?
    @EnvironmentObject private var transactionInteractor: TransactionInteractor
    @EnvironmentObject private var di: DI
    
    private var showEditLabelsSheet: Binding<Bool> {
        .init(
            get: { editingTransaction != nil },
            set: { _ in editingTransaction = nil }
        )
    }
    
    private var showEditNoteSheet: Binding<Bool> {
        .init(
            get: { editingTransactionNote != nil },
            set: { _ in editingTransactionNote = nil }
        )
    }
    
    private var isLoading: Bool {
        return transactionInteractor.ocrSuggestions.isLoading || isProcessingOCR || isCreatingTransactionsBySuggestions
    }
    
    var body: some View {
        buildStateView(transactionInteractor.transactions)
            .onAppear {
                transactionInteractor.loadTransactions()
            }
            .navigationTitle(Text(transactionInteractor.parentChestName))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreateTransactionSheet = true
                    } label: {
                        Label("Create new transaction", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showImageSourceSelection = true
                    } label: {
                        Label("Scan receipt", systemImage: "camera.viewfinder")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            transactionAscendingByDate.toggle()
                        } label: {
                            Label("Sort by date", systemImage: "arrow.up.arrow.down")
                        }
                        Button {
                            isReconcilingBalance.toggle()
                        } label: {
                            Label("Reconcile balance", systemImage: "pencil.and.list.clipboard")
                        }
                    } label: {
                        Label("...", systemImage: "ellipsis")
                    }
                }
            }.sheet(isPresented: $showCreateTransactionSheet) {
                CreateTransactionSheet(isPresented: $showCreateTransactionSheet)
            }.sheet(isPresented: $isReconcilingBalance) {
                ReconcileBalanceSheet(isPresented: $isReconcilingBalance)
            }.sheet(isPresented: showEditLabelsSheet) {
                SelectTransactionLabelsSheet(
                    isPresented: showEditLabelsSheet,
                    selectedLabels: editingTransaction!.labels,
                    onConfirm: { labels in
                        updateTransaction(editingTransaction!, setTransactionLabels: labels)
                    }
                )
                .environmentObject(di.container.getTransactionLabelInteractor())
            }.sheet(isPresented: showEditNoteSheet) {
                EditNoteSheet(
                    isPresented: showEditNoteSheet,
                    note: editingTransactionNote!.note,
                    onConfirm: { note in
                        updateTransaction(editingTransactionNote!, setNote: note)
                    }
                )
            }.sheet(isPresented: $showTransactionSuggestionSheet) {
                if case .data(let suggestions) = transactionInteractor.ocrSuggestions {
                    TransactionSuggestionSheet(
                        isPresented: $showTransactionSuggestionSheet,
                        suggestions: suggestions,
                        transferrableChests: transferrableChests,
                        onConfirm: { suggestions in
                            transactionInteractor.createTransactions(suggestions: suggestions) {
                                transactionInteractor.loadTransactions()
                            }
                            showTransactionSuggestionSheet = false
                        },
                        onDismiss: { showTransactionSuggestionSheet = false }
                    )
                }
            }
            .actionSheet(isPresented: $showImageSourceSelection) {
                ActionSheet(
                    title: Text("Scan Receipt"),
                    message: Text("Choose image source"),
                    buttons: [
                        .default(Text("Camera")) {
                            showCameraPermissionView = true
                        },
                        .default(Text("Photo Library")) {
                            showImagePicker = true
                        },
                        .cancel()
                    ]
                )
            }
            .fullScreenCover(isPresented: $showCameraPicker) {
                ImagePickerView(
                    sourceType: .camera, 
                    selectedImages: $selectedImages,
                    onImageSelected: { image in
                        processImageWithOCR(image)
                    }
                )
            }
            .photosPicker(
                isPresented: $showImagePicker,
                selection: $selectedImages,
                maxSelectionCount: 1,
                matching: .images
            )
            .alert(
                "Error",
                isPresented: .constant(alertError != nil),
                actions: {
                    Button(action: { alertError = nil }) {
                        Text("OK")
                    }
                },
                message: {
                    Text(alertError?.localizedDescription ?? "")
                }
            )
            .background(
                Group {
                    if showCameraPermissionView {
                        CameraPermissionView(
                            onPermissionGranted: {
                                showCameraPermissionView = false
                                showCameraPicker = true
                            },
                            onPermissionDenied: {
                                showCameraPermissionView = false
                            }
                        )
                    }
                }
            )
            .onChange(of: selectedImages) { newImages in
                processSelectedImages(newImages)
            }
            .onReceive(transactionInteractor.$ocrSuggestions) { loadable in
                if case .data(_) = loadable {
                    showTransactionSuggestionSheet = true
                } else if case .error(let error) = loadable {
                    alertError = error
                }
            }
            .fullScreenLoading(isLoading)
    }
}

private extension ChestDetail {
    @ViewBuilder
    func buildStateView(_ state: LoadableList<Transaction>) -> some View {
        switch state {
        case .data(let transactions):
            ZStack(alignment: .bottomTrailing) {
                TransactionList(
                    transactions: transactions.filterByAttributesIgnoringDiacritics(
                        keyPath: \.searchAttributes,
                        text: searchText
                    ),
                    parentChestName: transactionInteractor.parentChestName,
                    ascendingByDate: $transactionAscendingByDate,
                    editingTransaction: $editingTransaction,
                    editingTransactionNote: $editingTransactionNote,
                    searchText: .init(
                        get: { searchText },
                        set: { text in
                            guard text.trimmed != searchText.trimmed else { return }
                            let newValue = text.count > 2 ? text : ""
                            searchText = newValue
                        }
                    ),
                    onDeleteTransaction: deleteTransaction(_:)
                )
                Text("Balance: \(transactionInteractor.parentChestBalanceText)")
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .padding()
            }
        case .error(let error):
            Text(error.localizedDescription)
        case .loading:
            ProgressView()
        default:
            EmptyView()
        }
    }
    
    func updateTransaction(
        _ transaction: Transaction,
        setTransactionLabels labels: [TransactionLabel]
    ) {
        transactionInteractor.updateTransaction(
            editingTransaction!,
            setTransactionLabels: labels,
            completion: {
                transactionInteractor.loadTransactions()
                editingTransaction = nil
            }
        )
    }
    
    func updateTransaction(
        _ transaction: Transaction,
        setNote note: String?
    ) {
        transactionInteractor.updateTransaction(
            editingTransactionNote!,
            setNote: note,
            completion: {
                transactionInteractor.loadTransactions()
                editingTransactionNote = nil
            }
        )
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        transactionInteractor.deleteTransaction(
            transaction,
            completion: { transactionInteractor.loadTransactions() }
        )
    }
    
    func processImageWithOCR(_ image: UIImage) {
        isProcessingOCR = true
        transactionInteractor.performOCR(on: image)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [self] completion in
                    isProcessingOCR = false
                    if case .failure(let error) = completion {
                        alertError = error
                        print("OCR Error: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [self] response in
                    ocrResults = response.results
                    getSuggestionsFromOCRResults(response)
                }
            )
            .store(in: &cancellables)
    }
    
    func processSelectedImages(_ images: [PhotosPickerItem]) {
        guard !images.isEmpty else { return }
        
        // Process the first image for OCR
        let firstImage = images[0]
        
        firstImage.loadTransferable(type: Data.self) { result in
            switch result {
            case .success(let data):
                if let data = data, let uiImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        processImageWithOCR(uiImage)
                    }
                }
            case .failure(let error):
                alertError = error
                print("Failed to load image: \(error)")
            }
        }
        
        // Reset selection after processing
        selectedImages = []
    }
    
    func getSuggestionsFromOCRResults(_ ocrResponse: OCRResponse) {
        transactionInteractor.suggestionFromOCR(ocrResponse: ocrResponse)
    }
}

#Preview {
    let interactor: TransactionInteractor = .init(
        chest: ChestDTO.create(vaultId: "1", name: "Example chest"),
        repo: TransactionRepositoryStub(),
        ocrService: OCRServiceStub(),
        scanService: ScanServiceStub()
    )
    
    return NavigationStack {
        ChestDetail(transferrableChests: ChestRepositoryStub.data)
            .environmentObject(interactor)
            .environmentObject(DI.preview)
    }
}
