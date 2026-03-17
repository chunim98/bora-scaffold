//
//  UIView+.swift
//  BoraScaffold
//
//  Created by 신정욱 on 1/8/26.
//

import UIKit

extension UIView {
    /// 뷰의 계층(Responder Chain)을 타고 올라가서,
    /// 이 뷰를 관리하는 가장 가까운 UIViewController를 반환
    var parentVC: UIViewController? {
        var responder = next
        
        while let currentResponder = responder {
            if let vc = currentResponder as? UIViewController { return vc }
            responder = currentResponder.next
        }
        
        return nil
    }
}
