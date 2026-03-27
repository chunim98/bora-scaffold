//
//  RxCanvasView.swift
//  BoraScaffold
//
//  Created by 신정욱 on 3/26/26.
//

import UIKit

import RxSwift
import RxCocoa

final class RxCanvasView: UIView {
    
    // MARK: Properties
    
    private let bag = DisposeBag()
    
    /// 사용자가 그린 전체 드로잉 경로를 누적 관리
    private let drawingPath = UIBezierPath()
    
    /// 곡선 보간용 터치 좌표 저장 배열
    private var sampledPoints: [CGPoint] = []
    
    // MARK: Subjects
    
    /// 캔버스가 비어 있는지 여부 서브젝트 (출력)
    fileprivate let isEmptySubject = BehaviorSubject(value: true)
    
    /// 드로잉 결과 이미지 서브젝트 (출력)
    fileprivate let drawingImageSubject = BehaviorSubject(value: UIImage?.none)
    
    // MARK: Components
    
    /// 터치 즉시 드로잉을 시작하기 위한 입력 제스처
    /// - 롱프레스가 아니라 즉시 반응하는 드래그/드로잉 입력 제스처로 튜닝됨
    let drawingGesture = {
        let gesture = UILongPressGestureRecognizer()
        gesture.allowableMovement = .greatestFiniteMagnitude
        gesture.numberOfTouchesRequired = 1
        gesture.minimumPressDuration = 0
        gesture.cancelsTouchesInView = false
        gesture.delaysTouchesBegan = false
        gesture.delaysTouchesEnded = false
        return gesture
    }()
    
    /// 드로잉 경로를 화면에 렌더링하는 Shape Layer
    let strokeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.label.cgColor
        layer.contentsScale = UIScreen.main.scale
        layer.fillColor = nil
        layer.lineWidth = 2.5
        layer.lineCap = .round
        layer.lineJoin = .round
        return layer
    }()
    
    // MARK: Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDefaults()
        setupLayout()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 현재 뷰 크기에 맞춘 레이어 프레임 동기화
        strokeLayer.frame = bounds
    }
    
    // MARK: Defaults
    
    private func setupDefaults() {
        addGestureRecognizer(drawingGesture)
        clipsToBounds = true
    }
    
    // MARK: Layout
    
    private func setupLayout() { layer.addSublayer(strokeLayer) }
    
    // MARK: Bindings
    
    private func setupBindings() {
        drawingGesture.rx.event
            .bind(with: self) { owner, gesture in
                let point = gesture.location(in: owner)
                
                switch gesture.state {
                case .began: owner.beginStroke(at: point)
                case .changed: owner.appendStroke(at: point)
                case .ended, .cancelled, .failed: owner.finishStroke()
                default: break
                }
            }
            .disposed(by: bag)
    }
    
    // MARK: Gesture Handling
    
    /// 첫 드로잉 입력 시 새로운 경로 시작
    private func beginStroke(at point: CGPoint) {
        // 새 드로잉 시작용 좌표 버퍼 초기화
        sampledPoints = [point]
        // 현재 좌표를 Path 시작점으로 이동
        drawingPath.move(to: point)
        // 변경된 Path의 즉시 화면 반영
        strokeLayer.path = drawingPath.cgPath
    }
    
    /// 드로잉 이동 시 샘플링 좌표 반영 처리
    private func appendStroke(at point: CGPoint) {
        // 단일 좌표의 Path 보간 로직 전달
        appendPointToPath(point)
        
        // 누적된 Path의 Layer 반영
        strokeLayer.path = drawingPath.cgPath
        // 화면에 stroke가 그려진 시점이므로 외부에는 비어있지 않은 상태를 전달
        isEmptySubject.onNext(false)
    }
    
    /// 드로잉 종료 시 내부 상태 정리 처리
    private func finishStroke() {
        // 실질적으로 무언가 그려진 상태면, 드로잉 결과 이미지 외부로 전달 (포인트 1개는 그린 게 아님)
        if sampledPoints.count > 1 { drawingImageSubject.onNext(makeImage()) }
        
        // 다음 입력 영향 방지를 위한 좌표 버퍼 초기화
        sampledPoints.removeAll()
    }
    
    // MARK: Private Helpers
    
    /// 단일 좌표의 현재 Path 반영 처리
    private func appendPointToPath(_ point: CGPoint) {
        // 보간 계산용 새 좌표 추가
        sampledPoints.append(point)
        
        // 누적 좌표 개수에 따른 경로 추가 방식 분기
        switch sampledPoints.count {
        case 1:
            // 첫 좌표의 Path 시작 위치 지정
            drawingPath.move(to: point)
            
        case 2:
            // 두 좌표 기준 중간 지점 계산
            let middlePoint = midpoint(from: sampledPoints[0], to: sampledPoints[1])
            // 시작 구간 연결용 직선 추가
            drawingPath.addLine(to: middlePoint)
            
        default:
            // 곡선 제어점으로 사용할 직전 좌표 추출
            let previousPoint = sampledPoints[sampledPoints.count - 2]
            // 현재 계산 대상인 최신 좌표 추출
            let currentPoint = sampledPoints[sampledPoints.count - 1]
            // 곡선 끝점으로 사용할 중간 지점 계산
            let middlePoint = midpoint(from: previousPoint, to: currentPoint)
            // 직전 좌표 기반 2차 곡선 추가
            drawingPath.addQuadCurve(to: middlePoint, controlPoint: previousPoint)
        }
    }
    
    /// 두 좌표 사이 중간 지점 계산 메서드
    private func midpoint(
        from startPoint: CGPoint,
        to endPoint: CGPoint
    ) -> CGPoint {
        // x, y 평균값 기반 중간 좌표 생성
        CGPoint(
            x: (startPoint.x + endPoint.x) * 0.5,
            y: (startPoint.y + endPoint.y) * 0.5
        )
    }
    
    /// 드로잉 결과 이미지 생성
    private func makeImage() -> UIImage? {
        guard !bounds.isEmpty else { return nil }
        
        return UIGraphicsImageRenderer(
            bounds: bounds,
            format: .default()
        ).image { context in
            strokeLayer.render(in: context.cgContext)
        }
    }
    
    // MARK: Public Methods
    
    /// 외부에서 캔버스를 초기화할 때 사용
    func clear() {
        // 곡선 계산용 좌표 버퍼 초기화
        sampledPoints.removeAll()
        // 화면에 그려진 전체 경로 제거
        drawingPath.removeAllPoints()
        // 초기화된 Path의 Layer 반영
        strokeLayer.path = drawingPath.cgPath
        
        // 누적된 드로잉 결과가 제거됐으므로 외부에는 빈 상태를 다시 전달
        drawingImageSubject.onNext(nil)
        isEmptySubject.onNext(true)
    }
}

// MARK: Reactive Interface

@MainActor
extension Reactive where Base: RxCanvasView {
    /// 캔버스 비어있음 여부 스트림
    var isEmpty: Observable<Bool> { base.isEmptySubject.distinctUntilChanged() }
    
    /// 드로잉 결과 이미지 스트림
    var drawingImage: Observable<UIImage?> { base.drawingImageSubject }
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview { RxCanvasView() }
