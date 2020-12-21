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

class ImageLoader: ObservableObject, PageProtocol{
    private let downloader: ImageDownloader = KingfisherManager.shared.downloader
    private let cache: ImageCache = KingfisherManager.shared.cache
    private var task: DownloadTask? = nil
    @Published var image: UIImage? = nil
    
    deinit {
        //DataLog.d("deinit " , tag:self.tag)
        task?.cancel()
    }
    

    func image(url: String?) -> UIImage {
       
        guard let url = url else {
            return UIImage.from(color: Color.clear )
        }
        if url == "" { return UIImage.from(color: Color.clear ) }
        guard let _ = url.firstIndex(of: ":") else{
            DataLog.d("asset " + url , tag:self.tag)
            return UIImage(named: url) ?? UIImage.from(color: Color.clear )
        }
        guard let targetUrl = URL(string:url) else {
             DataLog.e("targetUrl error " + url , tag:self.tag)
            return UIImage.from(color: Color.clear)
        }
        guard let image = image else {
            //DataLog.d("targetUrl " + url , tag:self.tag)
            load(url: targetUrl)
            return UIImage.from(color: Color.clear)
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
                    //DataLog.d("cached " + key , tag:self.tag)
                    self.image = value.image
                case .failure(_):
                    //print(error.localizedDescription)
                    DataLog.e("cached error" + key , tag:self.tag)
                }
            }
        } else {
            self.task = downloader.downloadImage(with: url, options: nil, progressBlock: nil) {  [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    self.cache.storeToDisk(value.originalData, forKey: url.absoluteString)
                    self.image = value.image
                    //DataLog.d("loaded" + key , tag:self.tag)
                case .failure(let error):
                    DataLog.d(error.localizedDescription, tag:self.tag)
                    DataLog.e("loaded error " + key , tag:self.tag)
                }
            }
        }
    }

}
