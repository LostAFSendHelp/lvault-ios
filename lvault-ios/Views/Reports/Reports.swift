//
//  Reports.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 8/11/24.
//

import SwiftUI

struct Reports: View {
    @EnvironmentObject private var interactor: ReportInteractor
    
    var body: some View {
        NavigationStack {
            buildStateView(state: interactor.reportData)
                .onAppear { interactor.generateReports() }
                .navigationTitle(Text("Reports"))
        }
        .tabItem { Label("Reports", systemImage: "chart.bar.doc.horizontal") }
    }
}

private extension Reports {
    @ViewBuilder
    func buildStateView(state: LoadableList<ReportSectionData>) -> some View {
        switch state {
        case .data(let data):
            List(
                data.sorted(by: { $0.startOfMonth > $1.startOfMonth }),
                id: \.startOfMonth
            ) { sectionData in
                ReportSectionView(data: sectionData)
            }
        case .loading:
            ProgressView()
        case .error(let error):
            Text(error.localizedDescription)
        case .idle:
            EmptyView()
        }
    }
}

#Preview {
    Reports()
        .environmentObject(DI.preview.container.getReportInteractor())
}
