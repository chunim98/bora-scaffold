//
//  UICollectionView+RxCocoa.swift
//  BoraScaffold
//
//  Created by 신정욱 on 3/24/26.
//

import UIKit

import RxCocoa
import RxSwift

extension Reactive where Base: UICollectionView {
    /// 선택한 셀의 모델 스트림
    func selectedModel<Section: Sendable, Item: Sendable & Hashable>(
        _ dataSource: UICollectionViewDiffableDataSource<Section, Item>?
    ) -> Observable<Item> {
        itemSelected.compactMap { indexPath in
            // itemSelected는 UI 선택 이벤트라 메인 스레드에서만 옴.
            // itemIdentifier(for:)는 MainActor 메서드라 여기서 assumeIsolated 사용함.
            MainActor.assumeIsolated {
                dataSource?.itemIdentifier(for: indexPath)
            }
        }
    }
}
