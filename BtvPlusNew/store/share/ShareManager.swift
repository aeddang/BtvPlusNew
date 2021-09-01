//
//  ShareManager.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/04/23.
//

import Foundation
import UIKit
import SwiftUI

class ShareManager :PageProtocol {
    let pagePresenter:PagePresenter?
    init(pagePresenter:PagePresenter? = nil) {
        self.pagePresenter = pagePresenter
    }
    
    func share(_ shareable:Shareable,  completion: ((Bool) -> Void)? = nil){
        if shareable.image == nil , let imagePath = shareable.imagePath{
            share(pageID:shareable.pageID,
                  params:shareable.params,
                  isPopup:shareable.isPopup,
                  link: shareable.link,
                  text:shareable.text?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  linkText: shareable.linkText,
                  image:imagePath,
                  useDynamiclink: shareable.useDynamiclink,
                  completion:completion
                  )
        }else {
            share(pageID:shareable.pageID,
                  params:shareable.params,
                  isPopup:shareable.isPopup,
                  link: shareable.link,
                  text:shareable.text?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  linkText: shareable.linkText,
                  image:shareable.image,
                  useDynamiclink: shareable.useDynamiclink,
                  completion:completion
                  )
        }
    }
    
    func share(pageID:PageID?, params:[PageParam:Any]? = nil, isPopup:Bool = true,
               link:String? = nil, text:String? = nil, linkText:String? = nil,  image:String,
               useDynamiclink:Bool = true,  completion: ((Bool) -> Void)? = nil){
        self.pagePresenter?.isLoading = true
        var shareImg:UIImage? = nil
        
        DispatchQueue.global().async {
            let url = URL(string:image)
            let data = try? Data(contentsOf: url!)
            if let data = data{
                shareImg = UIImage(data: data)
            }
            DispatchQueue.main.async {
                self.pagePresenter?.isLoading = false
                self.share(pageID:pageID, params:params, isPopup:isPopup,
                           link:link, text:text, image:shareImg, useDynamiclink: useDynamiclink)
            }
            
        }
    }
    
    func share( pageID:PageID?, params:[PageParam:Any]? = nil, isPopup:Bool = true,
                link:String? = nil, text:String? = nil, linkText:String? = nil, image:UIImage? = nil,
                useDynamiclink:Bool = true,  completion: ((Bool) -> Void)? = nil){
        if let page = pageID {
            guard let qurry = WhereverYouCanGo.qurryIwillGo(
                pageID: page,
                params: params,
                isPopup: isPopup,
                pageIDX: 999)
            else { return }
            
            self.pagePresenter?.isLoading = true
                DispatchQueue.global().async {
                    let linkBuilder = DynamicLinkMamager.getDynamicLinkSocialBuilder(qurry:qurry)
                    linkBuilder?.shorten() { url, warnings, error in
                        guard let url = url else { return }
                        self.pagePresenter?.isLoading = false
                        let shareable =
                            SocialMediaShareable(
                                image: image ,
                                url:url,
                                text: text
                            )
                        SocialMediaSharingManage.share(shareable, completion: completion)
                    }
                }
            
        } else {
            guard let link = link else {
                let shareable =
                    SocialMediaShareable(
                        image: image ,
                        text: text
                    )
                    SocialMediaSharingManage.share(shareable, completion: completion)
                return
            }
            
            if useDynamiclink {
                self.pagePresenter?.isLoading = true
                DispatchQueue.global().async {
                    if let linkBuilder = DynamicLinkMamager.getDynamicLinkBuilder(link) {
                        linkBuilder.shorten() { url, warnings, error in
                            DispatchQueue.main.async {
                                self.pagePresenter?.isLoading = false
                                if let shorten = url?.absoluteString {
                                    if let shareHost = ApiPath.getRestApiPath(.WEB).toUrl()?.host{
                                        let replaceUrl = shareHost + "/s"
                                        if shorten.contains(DynamicLinkMamager.urlPreFix) {
                                            let replaced = shorten.replace( DynamicLinkMamager.urlPreFix, with: replaceUrl)
                                            let shareable =
                                                SocialMediaShareable(
                                                    image: image ,
                                                    url:replaced.toUrl(),
                                                    text: text,
                                                    linkText: linkText
                                                )
                                            SocialMediaSharingManage.share(shareable, completion: completion)
                                            return
                                        }
                                    }
                                }
                                share(originLink: link)
                            }
                        }
                        
                    } else {
                        DispatchQueue.main.async {
                            share(originLink: link)
                        }
                    }
                }
            } else {
                share(originLink: link)
            }
        }
        
        func share(originLink:String){
            let shareable =
                SocialMediaShareable(
                    image: image ,
                    url: originLink.toUrl(),
                    text: text,
                    linkText: linkText
                )
            SocialMediaSharingManage.share(shareable, completion: completion)
        }
    }
    

}
