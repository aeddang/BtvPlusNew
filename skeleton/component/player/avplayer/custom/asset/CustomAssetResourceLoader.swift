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
    static let scheme = "mainm3u8"
    private let fragmentsScheme = "fragmentsm3u8"
    private var m3u8String: String? = nil
    private var baseURL:String = ""
    private var delegate: CustomAssetPlayerDelegate? = nil
    private var info:AssetPlayerInfo? = nil
    init(m3u8URL: URL, playerDelegate:CustomAssetPlayerDelegate? = nil, assetInfo:AssetPlayerInfo? = nil) {
        if var components = URLComponents(string: m3u8URL.absoluteString) {
            components.query = nil
            self.baseURL = components.url?.deletingLastPathComponent().absoluteString ?? ""
        }
        delegate = playerDelegate
        self.info = assetInfo
        super.init()
    }
   
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                        shouldWaitForLoadingOfRequestedResource
        loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        
        guard let path = loadingRequest.request.url?.absoluteString else {return false}
        
        if !path.hasPrefix(Self.scheme)  { return false }
        guard let originPath = loadingRequest.request.url?.absoluteString.replace(Self.scheme, with: "") else {return false}
        if !originPath.hasSuffix(".m3u8") { return false }
        return handleRequest(loadingRequest, path: originPath)
    }
    
    func handleRequest(_ request: AVAssetResourceLoadingRequest, path:String) -> Bool {
        DataLog.d(path, tag:self.tag)
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
        let data = self.m3u8String!.data(using: .utf8)!
        request.dataRequest?.respond(with: data)
        request.finishLoading()
    }
    
  
}
