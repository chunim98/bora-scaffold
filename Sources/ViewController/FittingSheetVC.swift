//
//  FittingSheetVC.swift
//  BoraScaffold
//
//  Created by 신정욱 on 3/27/26.
//

import UIKit

/// 콘텐츠의 Auto Layout 높이에 맞춰
/// 시트 detent 높이를 자동으로 갱신하는 공용 베이스 뷰컨트롤러
class FittingSheetVC: UIViewController {
    
    // MARK: Properties
    
    /// 마지막으로 적용한 시트 높이
    /// 같은 높이를 반복 적용하지 않기 위해 저장해둠
    private var currentSheetHeight: CGFloat = 0
    
    // MARK: Life Cycle
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 레이아웃이 모두 반영된 시점마다
        // 현재 콘텐츠 높이를 다시 계산해서 시트 높이를 갱신함
        updateSheetHeight()
    }
    
    // MARK: Private Helper
    
    /// 현재 뷰의 실제 콘텐츠 높이를 계산해서
    /// sheetPresentationController의 detent 높이를 갱신함
    private func updateSheetHeight() {
        // 최신 제약 상태를 기준으로 정확한 높이를 구하기 위해, 먼저 강제로 한 번 레이아웃을 반영함
        view.layoutIfNeeded()
        
        /// systemLayoutSizeFitting 계산에 사용할 목표 사이즈
        /// - 너비는 현재 뷰 너비를 그대로 쓰고, 높이는 가능한 최소 높이를 구하도록 compressed size를 사용함
        let targetSize = CGSize(
            width: view.bounds.width,
            height: UIView.layoutFittingCompressedSize.height
        )
        
        /// Auto Layout 기준으로 현재 뷰가 필요로 하는 실제 높이
        /// - 가로는 현재 너비에 꼭 맞춰 계산하고, 세로는 콘텐츠가 필요한 만큼 유연하게 계산하도록 설정함
        let contentHeight = view.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        
        /// 실제 시트에 적용할 최종 높이 (safeAreaInsets 반영)
        let finalHeight =
        contentHeight - (view.safeAreaInsets.top + view.safeAreaInsets.bottom)
        
        // 잘못된 계산으로 0 이하가 나온 경우는 무시함
        guard finalHeight > 0 else { return }
        
        // 이전 높이와 거의 차이가 없으면 다시 적용하지 않음 (무한 루프 방지)
        guard abs(currentSheetHeight - finalHeight) > 0.5 else { return }
        
        // 현재 컨트롤러가 sheet로 표시된 상황이 아니면 갱신할 수 없으므로 종료함
        guard let sheet = sheetPresentationController else { return }
        
        // 이번에 계산된 높이를 현재 높이로 저장해둠
        currentSheetHeight = finalHeight
        
        // 시트 높이 변경을 자연스럽게 반영하기 위해 animateChanges 사용
        sheet.animateChanges {
            // detent를 새 높이 기준으로 다시 설정함
            sheet.detents = [.custom(
                identifier: .init("ContentFittingHeight"),
                resolver: { _ in finalHeight }
            )]
        }
    }
}
