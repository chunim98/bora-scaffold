//
//  UITableView+CombineCocoa.swift
//  BoraScaffold
//
//  Created by 신정욱 on 6/30/25.
//

import UIKit
import Combine

import CombineCocoa

extension UITableView {
    /// 선택한 셀의 모델 퍼블리셔
    func selectedModelPublisher<Section, Item>(
        dataSource: UITableViewDiffableDataSource<Section, Item>?
    ) -> AnyPublisher<Item, Never> where Item: Hashable {
        self.didSelectRowPublisher
            .compactMap { [weak dataSource] in dataSource?.itemIdentifier(for: $0) }
            .eraseToAnyPublisher()
    }
}
