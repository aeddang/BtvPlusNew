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
    @Published var event: ImageLoaderEvent? = nil {didSet{ if event != nil { event = nil} }}
    private let downloader: ImageDownloader = KingfisherManager.shared.downloader
    private let cache:ImageCache = KingfisherManager.shared.cache
    private var task: DownloadTask? = nil
    private var isLoading = false
   
    deinit {
        guard let task = task else {return}
        task.cancel()
    }
    
    func reload(url: String?){
        isLoading = false
        load(url: url)
    }
    
    @discardableResult
    func load(url: String?) -> Bool {
        if isLoading { return false}
        guard let url = url else {
            DataLog.e("targetUrl nil" , tag:self.tag)
            self.event = .error
            return false
        }
        if url == "" {
            DataLog.e("targetUrl empty" , tag:self.tag)
            self.event = .error
            return false
        }
        guard let targetUrl = URL(string:url) else {
            DataLog.e("targetUrl error " + url , tag:self.tag)
            self.event = .error
            return false
        }
        /*
        if !key.isEmpty {
            DataLog.d("load " + key , tag:"ImageView")
            DataLog.d("targetUrl " + targetUrl.absoluteString , tag:"ImageView")
        }
        */
        load(url: targetUrl)
        return true
    }
    
    @discardableResult
    func cash(url: String?) -> Bool {
        if isLoading { return false}
        guard let url = url else { return false}
        if cache.isCached(forKey: url ) {
            self.isLoading = true
            self.loadCash(path: url)
            return true
        }
        return false
    }
    
    private func load(url: URL, key:String = "") {
        self.isLoading = true
        let path = url.absoluteString
        if cache.isCached(forKey: path ) {
            self.loadCash(path: path)
        } else {
            self.loadServer(url: url, path: path)
        }
    }
    
    private func loadCash(path:String){
        cache.retrieveImage(forKey: path) {  [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                guard let img = value.image else {
                    DataLog.d("cache error crear" + path , tag:self.tag)
                    self.cache.removeImage(forKey: path)
                    self.isLoading = false
                    return
                }
                
                self.event = .complete(img)
                self.isLoading = false
                
            case .failure(_):
                self.cache.removeImage(forKey: path)
                self.isLoading = false
            }
        }
    }
    
    private func loadServer(url: URL, path:String){
        self.task = downloader.downloadImage(with: url, options: nil, progressBlock: nil) {  [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                self.cache.storeToDisk(value.originalData, forKey: path)
                self.event = .complete(value.image)
                self.isLoading = false
            case .failure(_):
                DataLog.e("loaded error " + path , tag:self.tag)
                self.event = .error
                self.isLoading = false
            }
        }
    }
}


class AsyncImageLoader: ObservableObject, PageProtocol{

    @Published var event: ImageLoaderEvent? = nil {didSet{ if event != nil { event = nil} }}
    private var cancellable: AnyCancellable?
    private var isLoading = false
   
    deinit {
        cancel()
    }
    
    func cancel() {
        cancellable?.cancel()
        cancellable = nil
    }
    
    @discardableResult
    func load(url: String?) -> Bool {
        if isLoading { return false}
        guard let url = url else { return false}
        if url == "" { return false}
        guard let targetUrl = URL(string:url) else {
            DataLog.e("targetUrl error " + url , tag:self.tag)
            return false
        }
        load(url: targetUrl)
        return true
    }
    
    private func load(url: URL) {
        self.isLoading = true
        let path = url.absoluteString
        let cache = KingfisherManager.shared.cache
        if cache.isCached(forKey: path) {
            cache.retrieveImage(forKey: path) {  [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    guard let img = value.image else {
                        cache.removeImage(forKey: path)
                        self.isLoading = false
                        return
                    }
                    
                    self.event = .complete(img)
                    self.isLoading = false
                    
                case .failure(_):
                    cache.removeImage(forKey: path)
                    self.isLoading = false
                }
            }
        } else {
            self.cancellable = URLSession.shared.dataTaskPublisher(for: url)
                .map { UIImage(data: $0.data) }
                .replaceError(with: nil)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] (image) in
                    guard let self = self else { return }
                    if let image = image {
                        if let data = image.pngData() {
                            cache.storeToDisk(data, forKey: path)
                        }
                        self.event = .complete(image)
                        self.isLoading = false
                        
                    } else {

                        self.event = .error
                        self.isLoading = false
                    }
              }
        }
    }
}
