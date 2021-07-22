//
//  Drm.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/19.
//

import Foundation

enum DRMError: Error {
    case certificate(reason:String)
    case contentId(reason:String)
    case spcData(reason:String)
    case ckcData(reason:String)
    case stream
    
    func getDescription() -> String {
        switch self {
        case .certificate(let reason):
            return "certificate error " + reason
        case .spcData(let reason):
            return "spcData error " + reason
        case .contentId(let reason):
            return "contentId error " + reason
        case .ckcData(let reason):
            return "ckcData error " + reason
        case .stream:
            return "stream error"
        }
    }
    
    func getDomain() -> String {
        return "drm"
    }
    
    func getCode() -> Int {
        return -3
    }
}

enum AssetLoadError: Error {
    case parse(reason:String)
    func getDescription() -> String {
        switch self {
        case .parse(let reason):
            return "parse error " + reason
        }
    }
    
    func getDomain() -> String {
        return "asset"
    }
    
    func getCode() -> Int {
        return -2
    }
}

enum AssetLoadEvent {
    case ready
}


class AssetPlayerInfo {
    private(set) var resolutions:[String] = []
    private(set) var captions:[String] = []
    private(set) var audios:[String] = []
    
    var selectedResolution:String? = nil
    var selectedCaption:String? = nil
    var selectedAudio:String? = nil
    
    func reset(){
        resolutions = []
        captions = []
        audios = []
    }
    func copy() -> AssetPlayerInfo{
        let new = AssetPlayerInfo()
        new.selectedResolution = self.selectedResolution
        new.selectedCaption = self.selectedCaption
        new.selectedAudio = self.selectedAudio
        return new
    }
    func addResolution(_ value:String){
        if self.resolutions.first(where: {$0 == value}) == nil {
            self.resolutions.append(value)
        }
    }
    func addCaption(_ value:String){
        if self.captions.first(where: {$0 == value}) == nil {
            self.captions.append(value)
        }
    }
    func addAudio(_ value:String){
        if self.audios.first(where: {$0 == value}) == nil {
            self.audios.append(value)
        }
    }
}

protocol CustomAssetPlayerDelegate{
    func onFindAllInfo(_ info: AssetPlayerInfo)
    func onAssetEvent(_ evt :AssetLoadEvent)
    func onAssetLoadError(_ error: PlayerError)
}
