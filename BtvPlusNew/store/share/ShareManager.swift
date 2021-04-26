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
    
    func share(_ shareable:Shareable){
        if shareable.image == nil , let imagePath = shareable.imagePath{
            share(pageID:shareable.pageID,
                  params:shareable.params,
                  isPopup:shareable.isPopup,
                  link: shareable.link,
                  text:shareable.text,
                  image:imagePath,
                  useDynamiclink: shareable.useDynamiclink
                  )
        }else {
            share(pageID:shareable.pageID,
                  params:shareable.params,
                  isPopup:shareable.isPopup,
                  link: shareable.link,
                  text:shareable.text,
                  image:shareable.image,
                  useDynamiclink: shareable.useDynamiclink
                  )
        }
    }
    
    func share(pageID:PageID?, params:[PageParam:Any]? = nil, isPopup:Bool = true,
               link:String? = nil, text:String? = nil, image:String,
               useDynamiclink:Bool = true){
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
                link:String? = nil, text:String? = nil, image:UIImage? = nil,
                useDynamiclink:Bool = true){
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
                        SocialMediaSharingManage.share(shareable)
                    }
                }
            
        } else {
            guard let link = link else { return }
            
            if useDynamiclink {
                self.pagePresenter?.isLoading = true
                DispatchQueue.global().async {
                    let linkBuilder = DynamicLinkMamager.getDynamicLinkBuilder(link)
                    linkBuilder?.shorten() { url, warnings, error in
                        guard let url = url else { return }
                        self.pagePresenter?.isLoading = false
                        let shareable =
                            SocialMediaShareable(
                                image: image ,
                                url:url,
                                text: text
                            )
                        SocialMediaSharingManage.share(shareable)
                    }
                }
            } else {

                let shareable =
                    SocialMediaShareable(
                        image: image ,
                        url: link.toUrl(),
                        text: text
                    )
                SocialMediaSharingManage.share(shareable)
            }
        }
    }

}
