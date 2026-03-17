//
//  Weak.swift
//  BoraScaffold
//
//  Created by 신정욱 on 1/13/26.
//

// 약한 참조를 담을 수 있는 컨테이너
struct Weak<T: AnyObject> {
    weak var value: T?
    
    init(_ value: T?) {
        self.value = value
    }
}
