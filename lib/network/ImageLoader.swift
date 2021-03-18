//
//  ImageLoader.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/10.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import UIKit.UIImage
import SwiftUI
import Combine
import Kingfisher

enum ImageLoaderEvent {
   case complete(UIImage), error, reset
}


class ImageLoader: ObservableObject, PageProtocol{
    private let downloader: ImageDownloader = KingfisherManager.shared.downloader
    private let cache: ImageCache = KingfisherManager.shared.cache
    private var task: DownloadTask? = nil
   
    @Published var event: ImageLoaderEvent? = nil {didSet{ if event != nil { event = nil} }}
   
    var image: UIImage? = nil
    deinit {
        guard let task = task else {return}
        task.cancel()
    }
    
    @discardableResult
    func image(url: String?) -> UIImage? {
        guard let url = url else { return nil }
        if url == "" { return nil }
        guard let targetUrl = URL(string:url) else {
            DataLog.e("targetUrl error " + url , tag:self.tag)
            return nil
        }
        
        guard let image = self.image else {
            load(url: targetUrl)
            return nil
        }
        return image
    }
    
    private func load(url: URL) {
        let key = url.absoluteString
        
        if cache.isCached(forKey: key) {
            cache.retrieveImage(forKey: key) {  [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    guard let img = value.image else {
                        DataLog.d("cache error crear" + key , tag:self.tag)
                        self.cache.removeImage(forKey: key)
                        return
                    }
                    self.image = img
                    self.event = .complete(img)
                    
                case .failure(_):
                    DataLog.d("cache error crear" + key , tag:self.tag)
                    self.cache.removeImage(forKey: key)
                   
                }
            }
        } else {
            
            
            self.task = downloader.downloadImage(with: url, options: nil, progressBlock: nil) {  [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    self.cache.storeToDisk(value.originalData, forKey: url.absoluteString)
                    self.image = value.image
                    self.event = .complete(value.image)
                case .failure(_):
                    DataLog.e("loaded error " + key , tag:self.tag)
                    self.event = .error
                }
            }
        }
    }
}
