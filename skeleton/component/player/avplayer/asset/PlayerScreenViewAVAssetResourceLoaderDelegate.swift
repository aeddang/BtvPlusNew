//
//  PlayerScreenView+Asset.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/15.
//
import Foundation
import SwiftUI
import Combine
import AVKit
import MediaPlayer

extension PlayerScreenView: AVAssetResourceLoaderDelegate { 
    static let mainScheme = "mainm3u8"
    
    func setDrm(_ data:FairPlayDrm?) {
        self.drmData = data  
    }
    
    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader, shouldWaitForRenewalOfRequestedResource renewalRequest: AVAssetResourceRenewalRequest) -> Bool {
        
        ComponentLog.d("shouldWaitForRenewalOfRequestedResource renewalRequest" , tag: self.tag + " AVAssetResource")
        return true
    }
    
    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader, shouldWaitForResponseTo authenticationChallenge: URLAuthenticationChallenge) -> Bool{
        ComponentLog.d("shouldWaitForResponseTo authenticationChallenge" , tag: self.tag + " AVAssetResource")
        return true
    }
    
    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        
        ComponentLog.d("shouldWaitForLoadingOfRequestedResource loadingRequest" , tag: self.tag + " AVAssetResource")
        guard let drmData = self.drmData else {
            ComponentLog.e("Unable to read the drmData." , tag: self.tag + " DRM")
            loadingRequest.finishLoading(with: NSError(domain: "com.icapps.error", code: -4, userInfo: nil))
            return false
        }
        // We first check if a url is set in the manifest.
        guard let url = loadingRequest.request.url else {
            ComponentLog.e("Unable to read the url/host data." , tag: self.tag + " DRM")
            loadingRequest.finishLoading(with: NSError(domain: "com.icapps.error", code: -1, userInfo: nil))
            return false
        }
        ComponentLog.d("🔑 " + url.absoluteString , tag: self.tag + " DRM")
                
            // When the url is correctly found we try to load the certificate date. Watch out! For this
            // example the certificate resides inside the bundle. But it should be preferably fetched from
            // the server.
        guard
            let certificateURL = Bundle.main.url(forResource: "certificate", withExtension: "der"),
            let certificateData = try? Data(contentsOf: certificateURL) else {
            ComponentLog.e("Unable to read the certificate data." , tag: self.tag + " DRM")
            loadingRequest.finishLoading(with: NSError(domain: "com.icapps.error", code: -2, userInfo: nil))
            return false
        }

        // Request the Server Playback Context.
        let contentId = drmData.contentId //"hls.icapps.com"
        guard
            let contentIdData = contentId.data(using: String.Encoding.utf8),
            let spcData = try? loadingRequest.streamingContentKeyRequestData(forApp: certificateData, contentIdentifier: contentIdData, options: nil),
            let dataRequest = loadingRequest.dataRequest else {
            loadingRequest.finishLoading(with: NSError(domain: "com.icapps.error", code: -3, userInfo: nil))
            ComponentLog.e("Unable to read the SPC data." , tag: self.tag + " DRM")
            return false
        }

        // Request the Content Key Context from the Key Server Module.
        let ckcURL = URL(string: drmData.ckcURL)!  //"https://hls.icapps.com/ckc"
        var request = URLRequest(url: ckcURL)
        request.httpMethod = "POST"
        request.httpBody = spcData
        
        let queue = OperationQueue()
        queue.qualityOfService = .background
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: queue)
        let task = session.dataTask(with: request) { data, response, error in
            if let data = data {
                // The CKC is correctly returned and is now send to the `AVPlayer` instance so we
                // can continue to play the stream.
                dataRequest.respond(with: data)
                loadingRequest.finishLoading()
            } else {
                ComponentLog.e("Unable to fetch the CKC.", tag: self.tag + " DRM")
                loadingRequest.finishLoading(with: NSError(domain: "com.icapps.error", code: -4, userInfo: nil))
            }
        }
        task.resume()
        return true
    }
}
