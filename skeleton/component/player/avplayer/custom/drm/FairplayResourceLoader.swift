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
        } else {
            return false
        }
    }
    
    @discardableResult
    func getLicenseData(_ request: AVAssetResourceLoadingRequest, drmData:FairPlayDrm) -> Bool {
        DataLog.d("getSpcData", tag: self.tag)
        guard let certificate = drmData.certificate else {
            self.delegate?.onAssetLoadError(.drm(.noCertificate))
            request.finishLoading(with: DRMError.noCertificate)
            return false
        }
        let contentId = drmData.contentId ?? "" // content id
        guard let contentIdData = contentId.data(using: String.Encoding.utf8) else {
            self.delegate?.onAssetLoadError(.drm(.noContentIdFound))
            request.finishLoading(with: DRMError.noContentIdFound)
            return false
        }
        DataLog.d("contentId " + contentId , tag: self.tag)
        DataLog.d("contentIdData " + contentIdData.base64EncodedString() , tag: self.tag)
                
        guard let spcData = try? request.streamingContentKeyRequestData(
                forApp: certificate,
                contentIdentifier: contentIdData) else {
            request.finishLoading(with: NSError(domain: "spcData", code: -3, userInfo: nil))
            DataLog.e("DRM: false to get SPC Data from video", tag: self.tag)
            self.delegate?.onAssetLoadError(.drm(.noSPCFound))
            request.finishLoading(with: DRMError.noSPCFound)
            return false
        }
        
        guard let ckcServer = URL(string: drmData.ckcURL) else {
            DataLog.e("ckc url error", tag: self.tag)
            self.delegate?.onAssetLoadError(.drm(.noLicenseUrl))
            request.finishLoading(with: DRMError.noLicenseUrl)
            return false
        }
        
        var licenseRequest = URLRequest(url: ckcServer)
        licenseRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        licenseRequest.httpMethod = "POST"
        var params = [String:String]()
        params["spc"] = spcData.base64EncodedString()
        params["assetId"] = contentId
        licenseRequest.httpBody = params.map{$0.key + "=" + $0.value.toPercentEncoding()}.joined(separator: "&").data(using: .utf8)
        
        let task = URLSession(configuration: URLSessionConfiguration.default).dataTask(with: licenseRequest) { data, response, error in
            guard let data = data else {
                DataLog.e("ckc nodata", tag: self.tag)
                self.delegate?.onAssetLoadError(.drm(.cannotEncodeCKCData))
                request.finishLoading(with: DRMError.cannotEncodeCKCData)
                return
            }
            var responseString = String(data: data, encoding: .utf8)
            responseString = responseString?.replacingOccurrences(of: "<ckc>", with: "").replacingOccurrences(of: "</ckc>", with: "")
            guard let str = responseString  else { return }
            DataLog.d("license key data " + str, tag: self.tag)
            
            //request.dataRequest?.respond(with: data)
            //request.finishLoading()
            //self.drm.isCompleted = true
            guard let ckcData = Data(base64Encoded:str, options: .ignoreUnknownCharacters)  else {
                DataLog.e("ckc base64Encoded", tag: self.tag)
                self.delegate?.onAssetLoadError(.drm(.cannotEncodeCKCData))
                request.finishLoading(with: DRMError.cannotEncodeCKCData)
                return
            }
            request.dataRequest?.respond(with: ckcData)
            request.finishLoading()
            self.drm.isCompleted = true
            
            /*
            var persistentKeyData: Data?
            do {
                persistentKeyData = try request.persistentContentKey(fromKeyVendorResponse: ckcData, options: nil)
            } catch {
                DataLog.e("Failed to get persistent key with error: \(error)", tag: self.tag)
                self.delegate?.onAssetLoadError(.drm(.unableToGeneratePersistentKey))
                request.finishLoading(with: DRMError.unableToGeneratePersistentKey)
                return
            }
            request.contentInformationRequest?.contentType = AVStreamingKeyDeliveryPersistentContentKeyType
            request.dataRequest?.respond(with: persistentKeyData!)
            request.finishLoading()
            */
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
            self.delegate?.onAssetLoadError(.drm(.noContentIdFound))
            request.finishLoading(with: DRMError.noContentIdFound)
            return false
        }
        if assetIDString == self.originURL.host {
            self.delegate?.onAssetLoadError(.drm(.noContentIdFound))
            request.finishLoading(with: DRMError.noContentIdFound)
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
