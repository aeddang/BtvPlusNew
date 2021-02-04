//
//  SocialMediaSharingManager.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import Social
import UIKit

struct SocialMediaShareable {
    let id = UUID.init().uuidString
    var image:UIImage?
    var url:URL?
    var text:String?
}

struct SocialMediaSharingManage{
    
    static func share(_ object: SocialMediaShareable, for serviceType: String) {
        let rootVC = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
        guard let vc = rootVC else { return }
        share(object,for: serviceType, from: vc)
    }
    
    static func share(_ object: SocialMediaShareable, for serviceType: String, from presentingVC: UIViewController) {
        if let composeVC = SLComposeViewController(forServiceType:serviceType) {
            composeVC.add(object.image)
            composeVC.add(object.url)
            composeVC.setInitialText(object.text)
            presentingVC.present(composeVC, animated: true, completion: nil)
        }
    }
    
    static func share(_ object: SocialMediaShareable) {
        let rootVC = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
        guard let vc = rootVC else { return }
        share(object, from: vc)
    }
    
    static func share(_ object: SocialMediaShareable, from presentingVC: UIViewController) {
        var  objectsToShare = Array<Any>()
        if let img = object.image { objectsToShare.append(img) }
        if let url = object.url { objectsToShare.append(url) }
        if let txt = object.text { objectsToShare.append(txt) }
    
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = presentingVC.view
        presentingVC.present(activityViewController, animated: true, completion: nil)
           
    }
}
