//
//  DynamicLinkManager.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/03.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import Firebase
struct DynamicLinkMamager{
    private static let deepLink = "http://btvplusnew.com"
    private static let urlPreFix = "https://btvplusnew.page.link"
    private static let bundleID = "com.skb.btvplus.BtvPlusNew"
    private static let scheme = "btvPlus"
    private static let packageName = "com.skb.btvplus"
    
    static func getDynamicLinkBuilder(_ link:String = deepLink) -> DynamicLinkComponents?{
        guard let link = URL(string: link) else { return nil }
        guard  let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: urlPreFix) else { return nil}
        linkBuilder.iOSParameters = DynamicLinkIOSParameters(bundleID: bundleID)
        linkBuilder.androidParameters = DynamicLinkAndroidParameters(packageName: packageName)
        return linkBuilder
    }
    
    static func getDynamicLinkSocialBuilder(_ link:String = deepLink, title:String? = nil, description:String? = nil, image:String? = nil)->DynamicLinkComponents?{
        guard  let linkBuilder = getDynamicLinkBuilder(link) else { return nil}
        let socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        socialMetaTagParameters.title = title
        socialMetaTagParameters.descriptionText =  description
        socialMetaTagParameters.imageURL = URL(string: image ?? "")
        linkBuilder.socialMetaTagParameters =  socialMetaTagParameters
        guard let url = linkBuilder.url else { return nil}
        ComponentLog.d("path : \(url)", tag: "DynamicLink")
        return linkBuilder
    }
    
    static func getDynamicLinkSocialBuilder(qurry:String, title:String? = nil, description:String? = nil, image:String? = nil)->DynamicLinkComponents?{
        let link = deepLink + "/?" + qurry
        return getDynamicLinkSocialBuilder(link, title:title, description:description, image:image)
    }
    
    
}
