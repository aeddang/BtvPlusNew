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
        if let drm = drm {
            if drm.certificate != nil {
                self.playAsset(drm: drm)
            } else {
                self.getCertificateData(drm: drm, delegate: playerDelegate)
            }
            
        } else {
            self.playAsset()
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func playAsset(drm:FairPlayDrm? = nil) {
        let customScheme = CustomAssetResourceLoader.scheme
        guard let customURL = drm == nil
                ? replaceURLWithScheme(customScheme,url: m3u8URL)
                : m3u8URL
        else { return }
        let asset = AVURLAsset(url: customURL)
        asset.resourceLoader.setDelegate(delegate, queue: loaderQueue)
        let playerItem = AVPlayerItem(asset: asset)
        self.replaceCurrentItem(with: playerItem)
    }
    
    func replaceURLWithScheme(_ scheme: String, url: URL) -> URL? {
        let urlString = scheme + url.absoluteString
        return URL(string: urlString)
    }
    
    func getCertificateData(drm:FairPlayDrm, delegate: CustomAssetPlayerDelegate? = nil)  {
        DataLog.d("getCertificateData", tag: self.tag)
        guard let url = URL(string:drm.certificateURL) else {
            DataLog.e("DRM: certificateData url error", tag: self.tag)
            delegate?.onAssetLoadError(.drm(reason: "certificate url"))
            return
        }
        let task = URLSession.shared.dataTask(with: url) {
            [weak self] (data, response, error) in
            guard error == nil, let data = data else
            {
                DataLog.e("DRM: certificateData error", tag: self?.tag ?? "")
                delegate?.onAssetLoadError(.drm(reason: "certificate data"))
                return
            }
            if let self = self {
                let cerData = data
                drm.certificate = cerData
                DataLog.d("DRM: certificate " + cerData.base64EncodedString() , tag: self.tag)
                self.playAsset(drm: drm)
            }
        }
        task.resume()
    }
    
}
