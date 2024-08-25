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
    @EnvironmentObject private var interactor: ReportInteractor
    
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
            .navigationTitle("Reports for [\(reportItem.label)]")
    }
}

private extension ReportItemDetailsView {
    @ViewBuilder
    func buildStateView(state: LoadableList<TransactionReportItem>) -> some View {
        switch state {
        case .data(let data):
            List(
                data.sorted(by: { $0.transactionDate > $1.transactionDate }),
                id: \.transactionId
            ) { item in
                TransactionReportItemRow(transactionReportItem: item)
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
