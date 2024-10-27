//
//  ArrayExtensions.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 6/30/24.
//

import Foundation

extension Array {
    mutating func removeAll<T: Equatable>(where keyPath: KeyPath<Element, T>, equals value: T?) {
        guard let value else { return }
        removeAll(where: { $0[keyPath: keyPath] == value })
    }
    
    func removingAll(where condition: (Element) -> Bool) -> Array {
        var new = self
        new.removeAll(where: condition)
        return new
    }
    
    func removingAll<T: Equatable>(where keyPath: KeyPath<Element, T>, equals value: T?) -> Array {
        var new = self
        new.removeAll(where: keyPath, equals: value)
        return new
    }
    
    func first<T: Equatable>(where keyPath: KeyPath<Element, T>, equals value: T) -> Element? {
        return first(where: { $0[keyPath: keyPath] == value })
    }
    
    func firstIndex<T: Equatable>(where keyPath: KeyPath<Element, T>, equals value: T) -> Int? {
        return firstIndex(where: { $0[keyPath: keyPath] == value })
    }
    
    func filterByTextIgnoringDiacritics(keyPath: KeyPath<Element, String>, text: String) -> [Element] {
        let trimmed = text.trimmed
        guard !trimmed.isEmpty else { return self }
        
        let searchText = trimmed.strippingDiacritics.lowercased()
        return filter({ $0[keyPath: keyPath].trimmed.strippingDiacritics.lowercased().contains(searchText) })
    }
    
    func filterByAttributesIgnoringDiacritics(keyPath: KeyPath<Element, [String]>, text: String) -> [Element] {
        let trimmed = text.trimmed
        guard !trimmed.isEmpty else { return self }
        
        let searchText = trimmed.strippingDiacritics.lowercased()
        return filter({ $0[keyPath: keyPath].contains(where: { $0.trimmed.strippingDiacritics.lowercased().contains(searchText) }) })
    }
}
