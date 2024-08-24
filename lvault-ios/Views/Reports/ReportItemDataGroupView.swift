//
//  ReportItemDataGroupView.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 8/24/24.
//

import SwiftUI

struct ReportItemData {
    let labelId: String
    let label: String
    let amount: Double
}

struct ReportItemDataGroup {
    let items: [ReportItemData]
    let totalAmount: Double
}

struct ReportItemDataGroupView: View {
    let title: String
    let group: ReportItemDataGroup
    @State private var isExpanded: Bool = true
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ForEach(group.items, id: \.labelId) { item in
                NavigationLink(
                    destination: { return Text(item.labelId) },
                    label: {
                        HStack {
                            Text(item.label)
                            Spacer()
                            Text(item.amount.signedDecimalText)
                        }.foregroundStyle(.secondary)
                    }
                )
            }
        } label: {
            HStack {
                Text(title)
                    .font(.system(size: 22, weight: .heavy))
                Spacer()
                Text(group.totalAmount.signedDecimalText)
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundStyle(group.totalAmount < 0 ? .red : .green)
            }
        }
    }
}
