//
//  ViewPager.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
open class ViewPagerModel: NavigationModel {
    @Published var request:ViewPagerUiEvent? = nil
    @Published var status:ViewPagerStatus = .stop
    @Published var event:ViewPagerEvent? = nil
}

enum ViewPagerUiEvent {
    case move(Int), jump(Int), next, prev, drag(CGFloat), draged , reset
}

enum ViewPagerStatus:String {
    case move, stop, pull
}

enum ViewPagerEvent:Equatable{
    case pull(CGFloat), pullCompleted, pullCancel
    
    static func ==(lhs: ViewPagerEvent, rhs: ViewPagerEvent) -> Bool {
        switch (lhs, rhs) {
        case ( .pull, .pull):return true
        case ( .pullCompleted, .pullCompleted):return true
        case ( .pullCancel, .pullCancel):return true
        default: return false
        }
    }
}
