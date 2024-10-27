//
//  ReportItemDetailsView.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 8/24/24.
//

import SwiftUI

struct ReportItemDetailsView: View {
    let reportItem: ReportItemData
    let fromMilliseconds: TimeInterval
    let toMilliseconds: TimeInterval
    @State private var itemsLoadable: LoadableList<TransactionReportItem> = .loading
    @State private var searchText: String = ""
    @EnvironmentObject private var interactor: ReportInteractor
    
    private var searchBinding: Binding<String> {
        .init(
            get: { searchText },
            set: { text in
                guard text.trimmed != searchText.trimmed else { return }
                let newValue = text.count > 2 ? text : ""
                searchText = newValue
            }
        )
    }
    
    var body: some View {
        buildStateView(state: itemsLoadable)
            .onAppear {
                interactor.getReportItemDetails(
                    labelId: reportItem.labelId,
                    fromMilliseconds: fromMilliseconds,
                    toMilliseconds: toMilliseconds,
                    into: $itemsLoadable
                )
            }
            .navigationTitle(reportItem.label)
    }
}

private extension ReportItemDetailsView {
    @ViewBuilder
    func buildStateView(state: LoadableList<TransactionReportItem>) -> some View {
        switch state {
        case .data(let data):
            let data = data
                .sorted(by: { $0.transactionDate > $1.transactionDate })
                .filterByTextIgnoringDiacritics(keyPath: \.note.orEmpty, text: searchText)
            let total = data.reduce(0, { current, next in current + next.amount }).signedDecimalText
            
            ZStack(alignment: .bottomTrailing) {
                List(
                    data,
                    id: \.transactionId
                ) { item in
                    TransactionReportItemRow(transactionReportItem: item)
                }.searchable(text: searchBinding)
                
                Text("Total: \(total)")
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .padding()
            }
        case .loading:
            ProgressView()
        case .error(let error):
            Text(error.localizedDescription)
        default:
            EmptyView()
        }
    }
}

#Preview {
    ReportItemDetailsView(
        reportItem: ReportItemData(labelId: "", label: "Preview label", amount: 0),
        fromMilliseconds: 0,
        toMilliseconds: Date().addingTimeInterval(60 * 60 * 24 * 5).millisecondsSince1970
    )
    .environmentObject(DI.preview.container.getReportInteractor())
}
