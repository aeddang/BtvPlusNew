import Foundation
import AVFoundation





class FairplayPlayer: AVPlayer , PageProtocol{
    private var loaderQueue = DispatchQueue(label: "CustomAssetPlayer")
    private var m3u8URL: URL
    private var delegate: FairplayResourceLoader
    
    init?(m3u8URL: URL, playerDelegate:CustomAssetPlayerDelegate? = nil, assetInfo:AssetPlayerInfo? = nil, drm:FairPlayDrm) {
        self.m3u8URL = m3u8URL
        self.delegate = FairplayResourceLoader(m3u8URL: m3u8URL, playerDelegate: playerDelegate, assetInfo:  assetInfo, drm: drm)
        super.init()
        if drm.certificate != nil {
            self.playAsset(drm: drm)
        } else {
            self.getCertificateData(drm: drm, delegate: playerDelegate)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func playAsset(drm:FairPlayDrm? = nil) {
       
        let asset = AVURLAsset(url: self.m3u8URL)
        asset.resourceLoader.setDelegate(delegate, queue: loaderQueue)
        let playerItem = AVPlayerItem(asset: asset)
        self.replaceCurrentItem(with: playerItem)
    }
    
    
    
    func getCertificateData(drm:FairPlayDrm, delegate: CustomAssetPlayerDelegate? = nil)  {
        DataLog.d("getCertificateData", tag: self.tag)
        guard let url = URL(string:drm.certificateURL) else {
            DataLog.e("DRM: certificateData url error", tag: self.tag)
            delegate?.onAssetLoadError(.drm(reason: "certificate url"))
            return
        }
        var certificateRequest = URLRequest(url: url)
        certificateRequest.httpMethod = "POST"
        let task = URLSession(configuration: URLSessionConfiguration.default).dataTask(with:certificateRequest) {
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
