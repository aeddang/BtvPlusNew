//
//  Shareable.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/04/23.
//

import Foundation

class Shareable {
    let pageID:PageID?
    var params:[PageParam:Any]?
    let isPopup:Bool
    let link:String?
    let text:String?
    var imagePath:String?
    var image:UIImage?
    let useDynamiclink:Bool
   
    init(
        pageID:PageID? = nil,
        params:[PageParam:Any]? = nil,
        isPopup:Bool = true,
        link:String? = nil,
        text:String? = nil,
        imagePath:String? = nil,
        image:UIImage? = nil,
        useDynamiclink:Bool = true
        ) {

        self.pageID = pageID
        self.params = params
        self.link = link
        self.text = text
        self.image = image
        self.imagePath = imagePath
        self.isPopup = isPopup
        self.useDynamiclink = useDynamiclink
    } 
}
