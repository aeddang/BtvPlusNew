//
//  CustomResourceLoaderDelegate.swift
//  External WebVTT Example
//
//  Created by Joris Weimar on 24/01/2019.
//  Copyright © 2019 Joris Weimar. All rights reserved.
//
import Foundation
import AVFoundation

class CustomAssetResourceLoader: NSObject, AVAssetResourceLoaderDelegate , PageProtocol{
    static let scheme = "Asset"
    private let fragmentsScheme = "fragmentsm3u8"
    private var m3u8String: String? = nil
    private var originURL:URL
    private var baseURL:String = ""
    private var delegate: CustomAssetPlayerDelegate?
    private var drm:FairPlayDrm? = nil
    private var info:AssetPlayerInfo? = nil
    init(m3u8URL: URL, playerDelegate:CustomAssetPlayerDelegate? = nil, assetInfo:AssetPlayerInfo? = nil, drm:FairPlayDrm? = nil) {
        self.originURL = m3u8URL
        if var components = URLComponents(string: m3u8URL.absoluteString) {
            components.query = nil
            self.baseURL = components.url?.deletingLastPathComponent().absoluteString ?? ""
        }
        self.drm = drm
        self.delegate = playerDelegate
        self.info = assetInfo
        super.init()
    }
   
    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource
        loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        
        if let drmData = self.drm {
            DataLog.d("DRM: init", tag: self.tag)
            if drmData.contentId == nil {
                return handleRequest(loadingRequest, path:self.originURL.absoluteString)
            } else if drmData.isCompleted {
                //self.delegate?.onAssetLoadError(.drm(reason: "drm"))
                return handleRequest(loadingRequest, path:self.originURL.absoluteString)
            } else {
                return self.getLicenseData(loadingRequest, drmData: drmData)
            }
        } else {
            guard let path = loadingRequest.request.url?.absoluteString else { return false }
            let originPath = path.hasPrefix(Self.scheme) ? path.replace(Self.scheme, with: "") : path
            return handleRequest(loadingRequest, path:originPath)
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
        guard let contentIdData = contentId.data(using:.utf8) else {
            self.delegate?.onAssetLoadError(.drm(reason: "contentIdData"))
            return false
        }
        DataLog.d("contentId " + contentId , tag: self.tag)
        DataLog.d("contentIdData " + contentIdData.base64EncodedString() , tag: self.tag)
                
        guard let spcData = try? request.streamingContentKeyRequestData(forApp: certificate, contentIdentifier: contentIdData, options: nil) else {
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
        
        let task = URLSession.shared.dataTask(with: licenseRequest) { data, response, error in
            guard let data = data else {
                DataLog.e("DRM: unable to fetch ckc key :/", tag: self.tag)
                self.delegate?.onAssetLoadError(.drm(reason: "ckcServer data"))
                request.finishLoading(with: NSError(domain: "ckcURL", code: -4, userInfo: nil))
                return
            }
            self.drm?.isCompleted = true
            var str = String(decoding: data, as: UTF8.self)
            str = str.replace("<ckc>", with: "")
            str = str.replace("</ckc>", with: "")
            let strData = str.data(using: .utf8)!
            
            DataLog.e("licenseData " + str, tag: self.tag)
            
            request.dataRequest?.respond(with: data)
            request.finishLoading()
        
        }
        task.resume()
        return true
    }
    
   
    
    @discardableResult
    func handleRequest(_ request: AVAssetResourceLoadingRequest, path:String) -> Bool {
        
        DataLog.d("handleRequest", tag:self.tag)
        guard let url = URL(string:path) else {return false}
        if let prevInfo = self.info { 
            self.info = prevInfo.copy()
        } else {
            self.info = AssetPlayerInfo()
        }
        /*
        if let info = self.info {
            DataLog.d(info.selectedResolution ?? "auto" , tag:self.tag + " handleRequest")
            DataLog.d(info.selectedCaption ?? "auto"  , tag:self.tag + " handleRequest")
            DataLog.d(info.selectedAudio ?? "auto"  , tag:self.tag + " handleRequest")
        }*/
        let task = URLSession.shared.dataTask(with: url) {
            [weak self] (data, response, error) in
            guard error == nil,
                let data = data else {
                    request.finishLoading(with: error)
                    return
            }
            if self?.drm?.isCompleted == true {
                request.dataRequest?.respond(with: data)
                request.finishLoading()
            }
            self?.processPlaylistWithData(data)
            self?.finishRequestWithMainPlaylist(request)
            if let info = self?.info {
                self?.delegate?.onFindAllInfo(info) 
            }
        }
        task.resume()
        return true
    }

   
    func processPlaylistWithData(_ data: Data) {
        guard let string = String(data: data, encoding: .utf8) else { return }
       
        let lines = string.components(separatedBy: "\n")
        var newLines = [String]()
        var iterator = lines.makeIterator()
        var useLine = true
        while let line = iterator.next() {
            let customLine = modifyLine(line, useLine:useLine)
            if customLine.isEmpty {
                useLine = false
            } else {
                if self.drm != nil {
                    newLines.append(customLine)   //.replace("skd://", with: "https://"))
                } else{
                    newLines.append(customLine)
                }
                
                useLine = true
            }
            
        }
        m3u8String = newLines.joined(separator: "\n")
        //DataLog.d(m3u8String ?? "empty" , tag:self.tag + " m3u8String")
    }
    func modifyLine(_ line: String, useLine:Bool = true)-> String {
        
        let components = line.components(separatedBy: ":")
        if components.count < 2 { return  line.hasSuffix(".m3u8")
            ? useLine
                ? self.baseURL + line
                : ""
            : line
        }
        guard let key = components.first else { return line }
        //DataLog.d(line, tag:self.tag + " origin")
        let datas = components[1].components(separatedBy: ",")
        var isUnSelectedLine = false
        var newLine = datas.reduce(key+":", { pre, cur in
            let set = cur.components(separatedBy: "=")
            if set.count != 2 {return pre + cur + ","}
            let type = set[0]
            var value = set[1]
            value = value.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range:nil)
            switch type {
            case "URI": return pre + type + "=\"" + self.baseURL + value  + "\","
            case "RESOLUTION":
                self.info?.addResolution(value)
                if let selValue = self.info?.selectedResolution {
                    if value != selValue { isUnSelectedLine = true }
                }
                return pre + cur  + ","
            case "CLOSED-CAPTIONS":  // SUBTITLES
                self.info?.addCaption(value)
                if let selValue = self.info?.selectedCaption {
                    if value != selValue { isUnSelectedLine = true }
                }
                return pre + cur  + ","
            case "AUDIO":
                self.info?.addAudio(value)
                if let selValue = self.info?.selectedAudio{
                    if value != selValue { isUnSelectedLine = true }
                }
                return pre + cur  + ","
            default : return pre + cur  + ","
            }
        })
        if !isUnSelectedLine {
            DataLog.d(newLine + " " + isUnSelectedLine.description , tag:self.tag + " newLine")
        }
        if isUnSelectedLine && newLine.hasPrefix("#EXT-X-STREAM-INF") {return ""}
        if newLine.last == "," { newLine.removeLast() }
        return newLine
    }
    
    func finishRequestWithMainPlaylist(_ request: AVAssetResourceLoadingRequest) {
        guard let data = self.m3u8String?.data(using: .utf8) else {
            self.delegate?.onAssetLoadError(.drm(reason: "no data MainPlaylist"))
            request.finishLoading(with: NSError(domain: "no data", code: -1, userInfo: nil))
            return
        }
        if let drm = self.drm {
            
            if drm.isCompleted {
                
                request.finishLoading()
            } else {
                guard let contentKeyIdentifierURL = request.request.url,
                    let assetIDString = contentKeyIdentifierURL.host
                else {
                    self.delegate?.onAssetLoadError(.drm(reason: "assetID"))
                    request.finishLoading(with: NSError(domain: "assetID", code: -4, userInfo: nil))
                    return
                }
                drm.contentId = assetIDString
                request.dataRequest?.respond(with: data)
                request.finishLoading()
            }
        
        } else {
            request.dataRequest?.respond(with: data)
            request.finishLoading()
        }
        
       
    }
    
  
}
