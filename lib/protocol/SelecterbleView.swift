//
//  SelecterbleView.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation

protocol SelecterbleProtocol{
    var isSelected:Bool { get set }
    var index:Int { get set }
}
extension SelecterbleProtocol {
    var isSelected: Bool  { get{false} set{isSelected = false}}
    var index:Int { get{0} set{} }
}

