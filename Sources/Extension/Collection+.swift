//
//  Collection+.swift
//  BoraScaffold
//
//  Created by 신정욱 on 11/27/25.
//

import Foundation

extension Collection {
    subscript (safe i: Index) -> Iterator.Element? {
        self.indices.contains(i) ? self[i] : nil
    }
}
