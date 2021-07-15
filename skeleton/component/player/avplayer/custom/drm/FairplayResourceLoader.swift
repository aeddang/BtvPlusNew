//
//  CustomResourceLoaderDelegate.swift
//  External WebVTT Example
//
//  Created by Joris Weimar on 24/01/2019.
//  Copyright © 2019 Joris Weimar. All rights reserved.
//
import Foundation
import AVFoundation

class FairplayResourceLoader: NSObject, AVAssetResourceLoaderDelegate , PageProtocol{
   
   
    private var originURL:URL
    private var delegate: CustomAssetPlayerDelegate?
    private var drm:FairPlayDrm
    private var info:AssetPlayerInfo? = nil
    init(m3u8URL: URL, playerDelegate:CustomAssetPlayerDelegate? = nil, assetInfo:AssetPlayerInfo? = nil, drm:FairPlayDrm) {
        self.originURL = m3u8URL
        self.drm = drm
        self.delegate = playerDelegate
        self.info = assetInfo
        
        super.init()
    }
   
    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource
        loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        
        if drm.contentId == nil {
            return handleRequest(loadingRequest, path:self.originURL.absoluteString)
        } else if drm.isCompleted {
            return redirectRequest(loadingRequest)
        } else {
            return false
        }
    }
    
    @discardableResult
    func getLicenseData(_ request: AVAssetResourceLoadingRequest, drmData:FairPlayDrm) -> Bool {
        DataLog.d("getSpcData", tag: self.tag)
        guard let certificate = drmData.certificate else {
            self.delegate?.onAssetLoadError(.drm(reason: "certificate"))
            return false
        }
        let contentId = drmData.contentId ?? "" // content id
        guard let contentIdData = contentId.data(using: String.Encoding.utf8) else {
            self.delegate?.onAssetLoadError(.drm(reason: "contentIdData"))
            return false
        }
        DataLog.d("contentId " + contentId , tag: self.tag)
        DataLog.d("contentIdData " + contentIdData.base64EncodedString() , tag: self.tag)
                
        guard let spcData = try? request.streamingContentKeyRequestData(
                forApp: certificate,
                contentIdentifier: contentIdData,
                options: [AVAssetResourceLoadingRequestStreamingContentKeyRequestRequiresPersistentKey: true as AnyObject]) else {
            request.finishLoading(with: NSError(domain: "spcData", code: -3, userInfo: nil))
            DataLog.e("DRM: false to get SPC Data from video", tag: self.tag)
            self.delegate?.onAssetLoadError(.drm(reason: "spcData"))
            return false
        }
        
        guard let ckcServer = URL(string: drmData.ckcURL) else {
            DataLog.e("ckc url error", tag: self.tag)
            self.delegate?.onAssetLoadError(.drm(reason: "ckcServer url"))
            request.finishLoading(with: NSError(domain: "ckcURL", code: -3, userInfo: nil))
            return false
        }
        
        var licenseRequest = URLRequest(url: ckcServer)
        licenseRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        licenseRequest.httpMethod = "POST"
        var params = [String:String]()
        params["spc"] = spcData.base64EncodedString()
        params["assetId"] = contentId
        licenseRequest.httpBody = params.map{$0.key + "=" + $0.value.toPercentEscape()}.joined(separator: "&").data(using: .utf8)
        
        
        let task = URLSession(configuration: URLSessionConfiguration.default).dataTask(with: licenseRequest) { data, response, error in
            guard let data = data else {
                DataLog.e("ckc nodata", tag: self.tag)
                self.delegate?.onAssetLoadError(.drm(reason: "ckcServer data"))
                request.finishLoading(with: NSError(domain: "ckc", code: -4, userInfo: nil))
                return
            }
            
            var str = String(decoding: data, as: UTF8.self)
            //str = str.replace("<ckc>", with: "")
            //str = str.replace("</ckc>", with: "")
            str = str.replace("\n", with: "")
            DataLog.e("licenseData " + str, tag: self.tag)
            
            //let modifyData:Data = Data(base64Encoded: str)
            guard let ckcData = Data(base64Encoded: data)  else {
                DataLog.e("ckc base64Encoded", tag: self.tag)
                self.delegate?.onAssetLoadError(.drm(reason: "ckcServer data"))
                request.finishLoading(with: NSError(domain: "ckc", code: -4, userInfo: nil))
                return
            }
            self.drm.isCompleted = true
            //let base64String = Array(str.utf8).toBase64()!
            //let strData = base64String.data(using: .utf8)!
            //request.dataRequest?.respond(with: data)
            //request.finishLoading()
            var persistentKeyData: Data?
            do {
                persistentKeyData = try request.persistentContentKey(fromKeyVendorResponse: ckcData, options: nil)
            } catch {
                DataLog.e("ckc persistentContentKey", tag: self.tag)
                self.delegate?.onAssetLoadError(.drm(reason: "ckc persistentContentKey"))
                return
            }
            request.contentInformationRequest?.contentType = AVStreamingKeyDeliveryPersistentContentKeyType
            request.dataRequest?.respond(with: persistentKeyData!)
            request.finishLoading()
        
        }
        task.resume()
        return true
    }
    
   
    
    @discardableResult
    func redirectRequest(_ request: AVAssetResourceLoadingRequest) -> Bool {
        

        guard let path = request.request.url?.absoluteString else {return false}
        let redirect = path.replace("skd://", with: "https://")
        guard let redirectUrl = URL(string:redirect) else {return false}
        let redirectRequest = URLRequest(url: redirectUrl)
        DataLog.d("redirectRequest " + redirect, tag:self.tag)
        
        //redirectRequest.httpMethod = "POST"
        let task = URLSession(configuration: URLSessionConfiguration.default).dataTask(with: redirectRequest) {
            (data, response, error) in
            guard error == nil,
                let data = data else {
                    request.finishLoading(with: error)
                    return
            }
            request.dataRequest?.respond(with:data)
            request.finishLoading()
            
        }
        task.resume()
        return true
    }
    
    func handleRequest(_ request: AVAssetResourceLoadingRequest, path:String) -> Bool {
        
        DataLog.d("handleRequest", tag:self.tag)
        
        guard let contentKeyIdentifierURL = request.request.url,
            let assetIDString = contentKeyIdentifierURL.host
        else {
            self.delegate?.onAssetLoadError(.drm(reason: "assetID"))
            request.finishLoading(with: NSError(domain: "assetID", code: -4, userInfo: nil))
            return false
        }
        if assetIDString == self.originURL.host {
            self.delegate?.onAssetLoadError(.drm(reason: "assetID"))
            request.finishLoading(with: NSError(domain: "assetID", code: -4, userInfo: nil))
            return false
    
        }
        drm.contentId = assetIDString
        return self.getLicenseData(request, drmData: drm)
        
        /*
        let task = URLSession(configuration: URLSessionConfiguration.default).dataTask(with: url) {
            [weak self] (data, response, error) in
            guard error == nil,
                let data = data else {
                    request.finishLoading(with: error)
                    return
            }
            if self?.drm.isCompleted == true {
               
                request.finishLoading()
            } else {
                guard let contentKeyIdentifierURL = request.request.url,
                    let assetIDString = contentKeyIdentifierURL.host
                else {
                    self?.delegate?.onAssetLoadError(.drm(reason: "assetID"))
                    request.finishLoading(with: NSError(domain: "assetID", code: -4, userInfo: nil))
                    return
                }
                if assetIDString == self?.originURL.host {
                    self?.delegate?.onAssetLoadError(.drm(reason: "assetID"))
                    request.finishLoading(with: NSError(domain: "assetID", code: -4, userInfo: nil))
            
                } else if let drm = self?.drm{
                    drm.contentId = assetIDString
                    self?.getLicenseData(request, drmData: drm)
                }
            }
        }
        task.resume()
        return true
        */
    }
}
