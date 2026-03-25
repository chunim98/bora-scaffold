//
//  SignatureCanvasView.swift
//  BoraScaffold
//
//  Created by 신정욱 on 3/26/26.
//

import UIKit

final class SignatureCanvasView: UIView {
    
    // MARK: Properties
    
    /// 사용자가 그린 전체 선 경로 누적 관리용 Path
    private let drawingPath = UIBezierPath()
    
    /// 곡선 보간용 터치 좌표 저장 배열
    private var sampledPoints: [CGPoint] = []
    
    // MARK: Components
    
    /// 실제 서명 선 렌더링용 Shape Layer
    private let strokeLayer = {
        let layer = CAShapeLayer()
        // 현재 선 색상 적용
        layer.strokeColor = UIColor.label.cgColor
        // 채우기 없는 외곽선 스타일 사용
        layer.fillColor = nil
        // 현재 선 두께 적용
        layer.lineWidth = 2.5
        // 선 시작점과 끝점의 둥근 처리
        layer.lineCap = .round
        // 선 꺾임 지점의 둥근 연결 처리
        layer.lineJoin = .round
        // 화면 배율 기준 렌더링 품질 설정
        layer.contentsScale = UIScreen.main.scale
        return layer
    }()
    
    // MARK: Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDefaults()
        setupLayout()
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
        isMultipleTouchEnabled = false
    }
    
    // MARK: Layout
    
    private func setupLayout() {
        layer.addSublayer(strokeLayer)
    }
    
    // MARK: Touch Handling
    
    /// 첫 터치 시 새로운 스트로크 시작 처리
    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        // 시작 터치 존재 여부 확인
        guard let touch = touches.first else { return }
        
        // 현재 뷰 기준 첫 터치 좌표 추출
        let point = touch.location(in: self)
        // 새 스트로크 시작용 좌표 버퍼 초기화
        sampledPoints = [point]
        // 현재 좌표를 Path 시작점으로 이동
        drawingPath.move(to: point)
        // 변경된 Path의 즉시 화면 반영
        strokeLayer.path = drawingPath.cgPath
    }
    
    /// 터치 이동 시 샘플링 좌표 반영 처리
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 기준 터치 존재 여부 확인
        guard let touch = touches.first else { return }
        
        // coalescedTouches 기반 촘촘한 좌표 수집
        let coalescedTouches = event?.coalescedTouches(for: touch) ?? [touch]
        
        // 샘플링된 모든 터치의 순차 반영
        for touch in coalescedTouches {
            // 현재 뷰 기준 터치 좌표 변환
            let point = touch.location(in: self)
            // 단일 좌표의 Path 보간 로직 전달
            appendPointToPath(point)
        }
        
        // 누적된 Path의 Layer 반영
        strokeLayer.path = drawingPath.cgPath
    }
    
    /// 터치 종료 시 임시 좌표 정리 처리
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 다음 스트로크를 위한 좌표 버퍼 초기화
        sampledPoints.removeAll()
    }
    
    /// 터치 취소 시 내부 상태 정리 처리
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 다음 입력 영향 방지를 위한 좌표 버퍼 초기화
        sampledPoints.removeAll()
    }
    
    // MARK: Private Helpers
    
    /// 단일 좌표의 현재 Path 반영 처리
    private func appendPointToPath(_ point: CGPoint) {
        // 보간 계산용 새 좌표 추가
        sampledPoints.append(point)
        
        // 누적 좌표 개수에 따른 선 추가 방식 분기
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
    
    // MARK: Public Methods
    
    /// 외부 노출용 서명 초기화 메서드
    func clear() {
        // 곡선 계산용 좌표 버퍼 초기화
        sampledPoints.removeAll()
        // 화면에 그려진 전체 경로 제거
        drawingPath.removeAllPoints()
        // 초기화된 Path의 Layer 반영
        strokeLayer.path = drawingPath.cgPath
    }
    
    /// 현재 서명 선 기준 이미지 추출 메서드
    func exportSignatureImage() -> UIImage? {
        guard !bounds.isEmpty else { return nil }
        
        return UIGraphicsImageRenderer(
            bounds: bounds,
            format: .default()
        ).image { context in
            strokeLayer.render(in: context.cgContext)
        }
    }
}
