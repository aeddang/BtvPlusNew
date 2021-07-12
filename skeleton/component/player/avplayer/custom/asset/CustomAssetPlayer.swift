import Foundation
import AVFoundation


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
    func onAssetLoadError(_ error: PlayerError)
}

class CustomAssetPlayer: AVPlayer , PageProtocol{
    private var loaderQueue = DispatchQueue(label: "CustomAssetPlayer")
    private var m3u8URL: URL
    private var delegate: CustomAssetResourceLoader
    
    init?(m3u8URL: URL, playerDelegate:CustomAssetPlayerDelegate? = nil, assetInfo:AssetPlayerInfo? = nil, drm:FairPlayDrm? = nil) {
        self.m3u8URL = m3u8URL
        self.delegate = CustomAssetResourceLoader(m3u8URL:m3u8URL, playerDelegate: playerDelegate, assetInfo:assetInfo, drm: drm)
        super.init()
        let customScheme = CustomAssetResourceLoader.scheme
        guard let customURL = replaceURLWithScheme(customScheme,
                                                   url: m3u8URL) else {
                                                    return nil
        }
        let asset = AVURLAsset(url: customURL)
        asset.resourceLoader.setDelegate(delegate, queue: loaderQueue)
        let playerItem = AVPlayerItem(asset: asset)
        self.replaceCurrentItem(with: playerItem)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func replaceURLWithScheme(_ scheme: String, url: URL) -> URL? {
        let urlString = scheme + url.absoluteString
        return URL(string: urlString)
    }
    
}
