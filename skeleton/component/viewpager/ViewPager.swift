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
}

enum ViewPagerUiEvent {
    case move(Int), jump(Int), next, drag(CGFloat), draged , reset
}

enum ViewPagerStatus:String {
    case move, stop
}
