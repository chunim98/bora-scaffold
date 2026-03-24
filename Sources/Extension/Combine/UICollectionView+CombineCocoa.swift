//
//  UICollectionView+CombineCocoa.swift
//  BoraScaffold
//
//  Created by 신정욱 on 5/12/25.
//

import UIKit
import Combine

import CombineCocoa

extension UICollectionView {
    /// 선택한 셀의 모델 퍼블리셔
    func selectedModelPublisher<Section: Sendable, Item: Sendable & Hashable>(
        _ dataSource: UICollectionViewDiffableDataSource<Section, Item>?
    ) -> AnyPublisher<Item, Never> {
        didSelectItemPublisher
            .compactMap { [weak dataSource] in dataSource?.itemIdentifier(for: $0) }
            .eraseToAnyPublisher()
    }
}
