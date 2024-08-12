//
//  ReportSectionView.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 8/11/24.
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

struct ReportSectionData {
    let startOfMonth: TimeInterval
    let spendings: ReportItemDataGroup
    let earnings: ReportItemDataGroup
    
    var total: Double {
        return spendings.totalAmount + earnings.totalAmount
    }
}

struct ReportItemDataGroupView: View {
    let title: String
    let group: ReportItemDataGroup
    @State private var isExpanded: Bool = true
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ForEach(group.items, id: \.labelId) { item in
                HStack {
                    Text(item.label)
                    Spacer()
                    Text(item.amount.signedDecimalText)
                }.foregroundStyle(.secondary)
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

struct ReportSectionView: View {
    let data: ReportSectionData
    
    var body: some View {
        Section(data.startOfMonth.millisecondToDate.MMMMyyyyGMT) {
            ReportItemDataGroupView(title: "Spent", group: data.spendings)
            ReportItemDataGroupView(title: "Earned", group: data.earnings)
            HStack {
                Text(data.total >= 0 ? "Net gain" : "Net loss")
                    .font(.system(size: 22, weight: .heavy))
                Spacer()
                Text(data.total.signedDecimalText)
                    .foregroundStyle(data.total < 0 ? .red : .green)
                    .font(.system(size: 22, weight: .heavy))
            }
        }
    }
}

#Preview {
    let spendings: [ReportItemData] = [
        .init(labelId: "s1", label: "Spent 1", amount: -1000),
        .init(labelId: "s2", label: "Spent 2", amount: -2070),
        .init(labelId: "s3", label: "Spent 3", amount: -3900)
    ]
    
    let earnings: [ReportItemData] = [
        .init(labelId: "e1", label: "Earned 1", amount: 1050),
        .init(labelId: "e2", label: "Earned 2", amount: 2050),
        .init(labelId: "e3", label: "Earned 3", amount: 3050)
    ]
    
    let data: ReportSectionData = .init(
        startOfMonth: 0,
        spendings: .init(items: spendings, totalAmount: -6970),
        earnings: .init(items: earnings, totalAmount: 6150)
    )
    
    return List() {
        ReportSectionView(data: data)
        ReportSectionView(data: data)
        ReportSectionView(data: data)
    }.listStyle(SidebarListStyle())
    
}
