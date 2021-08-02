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
    private var baseURL:String? = nil
    private var delegate: CustomAssetPlayerDelegate?
    private var drm:FairPlayDrm? = nil
    private var info:AssetPlayerInfo? = nil
    init(m3u8URL: URL, playerDelegate:CustomAssetPlayerDelegate? = nil, assetInfo:AssetPlayerInfo? = nil, drm:FairPlayDrm? = nil) {
        self.originURL = m3u8URL
        if let drm = drm {
            self.drm = drm
        } else {
            if var components = URLComponents(string: m3u8URL.absoluteString) {
                components.query = nil
                self.baseURL = components.url?.deletingLastPathComponent().absoluteString ?? ""
            }
        }
        self.delegate = playerDelegate
        self.info = assetInfo
        super.init()
    }
   
    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource
        loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        if let drmData = self.drm {
            
            if loadingRequest.request.url?.absoluteString.hasPrefix("skd://") == true {
                DataLog.d("drm handle", tag: self.tag)
                return handleRequest(loadingRequest)
                
            } else {
                DataLog.d("drm handle manifast", tag: self.tag)
                return handleRequest(loadingRequest)
               // return handleManifast(loadingRequest, path:self.originURL.absoluteString)
            }
        } else {
            guard let path = loadingRequest.request.url?.absoluteString else { return false }
            let originPath = path.hasPrefix(Self.scheme) ? path.replace(Self.scheme, with: "") : path
            return handleManifast(loadingRequest, path:originPath)
        }
    }
    
    @discardableResult
    func getLicenseData(_ request: AVAssetResourceLoadingRequest, drmData:FairPlayDrm) -> Bool {
        DataLog.d("getSpcData", tag: self.tag)
        guard let certificate = drmData.certificate else {
            
            let drmError:DRMError = .certificate(reason: "not found certificate data")
            DataLog.e(drmError.getDescription(), tag: self.tag)
            delegate?.onAssetLoadError(.drm(drmError))
            request.finishLoading(with:NSError(domain: drmError.getDomain(), code:drmError.getCode(), userInfo: nil))
            return false
        }
        
        guard let contentId = drmData.contentId else {
            let drmError:DRMError = .contentId(reason: "not found contentId")
            DataLog.e(drmError.getDescription(), tag: self.tag)
            delegate?.onAssetLoadError(.drm(drmError))
            request.finishLoading(with:NSError(domain: drmError.getDomain(), code:drmError.getCode(), userInfo: nil))
            return false
        }
        guard let contentIdData = contentId.data(using:.utf8) else {
            let drmError:DRMError = .contentId(reason: "invalid contentId")
            DataLog.e(drmError.getDescription(), tag: self.tag)
            delegate?.onAssetLoadError(.drm(drmError))
            request.finishLoading(with:NSError(domain: drmError.getDomain(), code:drmError.getCode(), userInfo: nil))
            return false
        }
        DataLog.d("contentId " + contentId , tag: self.tag)
        DataLog.d("contentIdData " + contentIdData.base64EncodedString() , tag: self.tag)
        guard let spcData = try? request.streamingContentKeyRequestData(forApp: certificate, contentIdentifier: contentIdData, options: nil) else {
            let drmError:DRMError = .spcData(reason: "invalid spcData")
            DataLog.e(drmError.getDescription(), tag: self.tag)
            delegate?.onAssetLoadError(.drm(drmError))
            request.finishLoading(with:NSError(domain: drmError.getDomain(), code:drmError.getCode(), userInfo: nil))
            return false
        }
        
        guard let ckcServer = URL(string: drmData.ckcURL) else {
            let drmError:DRMError = .ckcData(reason: "invalid license url")
            DataLog.e(drmError.getDescription(), tag: self.tag)
            delegate?.onAssetLoadError(.drm(drmError))
            request.finishLoading(with:NSError(domain: drmError.getDomain(), code:drmError.getCode(), userInfo: nil))
            return false
        }
        
        var licenseRequest = URLRequest(url: ckcServer)
        licenseRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        licenseRequest.httpMethod = "POST"
        var params = [String:String]()
        params["spc"] = spcData.base64EncodedString()
        params["assetId"] = contentId
        let body = params.map{$0.key + "=" + $0.value.toPercentEncoding()}.joined(separator: "&").data(using: .utf8)
        licenseRequest.httpBody = body
        if let body = body {
            DataLog.d("body " +  (String(data: body, encoding: .utf8) ?? "invalid data") , tag: self.tag)
        }
        let task = URLSession.shared.dataTask(with: licenseRequest) { data, response, error in
            guard let data = data else {
                let drmError:DRMError = .ckcData(reason: "no ckcData")
                DataLog.e(drmError.getDescription(), tag: self.tag)
                self.delegate?.onAssetLoadError(.drm(drmError))
                request.finishLoading(with:NSError(domain: drmError.getDomain(), code:drmError.getCode(), userInfo: nil))
                return
            }
            
            guard let responseString = String(data: data, encoding: .utf8) else {
                let drmError:DRMError = .ckcData(reason: "invalid ckcData")
                DataLog.e(drmError.getDescription(), tag: self.tag)
                self.delegate?.onAssetLoadError(.drm(drmError))
                request.finishLoading(with:NSError(domain: drmError.getDomain(), code:drmError.getCode(), userInfo: nil))
                return
            }
            
            let ckcKey = responseString
                .replacingOccurrences(of:"\n<ckc>", with: "")
                .replacingOccurrences(of:"</ckc>\n", with: "")
                .replacingOccurrences(of: "<ckc>", with: "")
                .replacingOccurrences(of: "</ckc>", with: "")
            
            // DataLog.e("licenseData " + ckcKey, tag: self.tag)
            if let ckcData = Data(base64Encoded:ckcKey) {
                DataLog.e("drm play ready", tag: self.tag)
                self.drm?.isCompleted = true
                request.dataRequest?.respond(with:ckcData)
                request.finishLoading()
                self.delegate?.onAssetEvent(.ready)
            } else {
                let drmError:DRMError = .ckcData(reason: "invalid ckc key")
                DataLog.e(drmError.getDescription(), tag: self.tag)
                self.delegate?.onAssetLoadError(.drm(drmError))
                request.finishLoading(with:NSError(domain: drmError.getDomain(), code:drmError.getCode(), userInfo: nil))
            }
        }
        task.resume()
        return true
    }

    func handleRequest(_ request: AVAssetResourceLoadingRequest) -> Bool {
        if let drmData = self.drm {
            guard let assetIDString = request.request.url?.absoluteString.replace("skd://", with: "")
            else {
                    let drmError:DRMError = .contentId(reason: "no contentId")
                    DataLog.e(drmError.getDescription(), tag: self.tag)
                    self.delegate?.onAssetLoadError(.drm(drmError))
                    request.finishLoading(with:NSError(domain: drmError.getDomain(), code:drmError.getCode(), userInfo: nil))
                    return false
            }
            drmData.contentId = assetIDString
            return self.getLicenseData(request, drmData: drmData)
        } else {
            let drmError:DRMError = .stream
            DataLog.e(drmError.getDescription(), tag: self.tag)
            self.delegate?.onAssetLoadError(.drm(drmError))
            request.finishLoading(with:NSError(domain: drmError.getDomain(), code:drmError.getCode(), userInfo: nil))
            return false
        }
    }
    

    func handleManifast(_ request: AVAssetResourceLoadingRequest, path:String) -> Bool {
        guard let url = URL(string:path) else {return false}
        if let prevInfo = self.info { 
            self.info = prevInfo.copy()
        } else {
            self.info = AssetPlayerInfo()
        }
        
        if let info = self.info {
            DataLog.d(info.selectedResolution ?? "auto" , tag:self.tag + " handleRequest")
            DataLog.d(info.selectedCaption ?? "auto"  , tag:self.tag + " handleRequest")
            DataLog.d(info.selectedAudio ?? "auto"  , tag:self.tag + " handleRequest")
        }
        let task = URLSession.shared.dataTask(with: url) {
            [weak self] (data, response, error) in
            guard error == nil,
                let data = data else {
                    request.finishLoading(with: error)
                    return
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
                newLines.append(customLine)
                useLine = true
            }
            
        }
        m3u8String = newLines.joined(separator: "\n")
        DataLog.d(m3u8String ?? "empty" , tag:self.tag + " m3u8String")
    }
    func modifyLine(_ line: String, useLine:Bool = true)-> String {
        
        let components = line.components(separatedBy: ":")
        if components.count < 2 {
            if let base  = self.baseURL {
                return
                    line.hasSuffix(".m3u8")
                        ? useLine
                            ? base + line
                            : ""
                        : line
            } else {
                return line
            }
        }
        guard let key = components.first else { return line }
        let datas = components[1].components(separatedBy: ",")
        var isUnSelectedLine = false
        var newLine = datas.reduce(key+":", { pre, cur in
            let set = cur.components(separatedBy: "=")
            if set.count != 2 {return pre + cur + ","}
            let type = set[0]
            var value = set[1]
            value = value.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range:nil)
            switch type {
            case "URI":
                if self.drm != nil {
                    return pre + cur  + ","
                }
                if let base = self.baseURL {
                    return pre + type + "=\"" + base + value  + "\","
                } else {
                    return pre + cur  + ","
                }
                
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
            let error:AssetLoadError = .parse(reason: "invalid m3u8String")
            DataLog.e(error.getDescription(), tag: self.tag)
            self.delegate?.onAssetLoadError(.asset(error))
            request.finishLoading(with:NSError(domain: error.getDomain(), code:error.getCode(), userInfo: nil))
            return
        }
        
        request.dataRequest?.respond(with: data)
        request.finishLoading()
    
    }
    
  
}
