import Foundation
import AVFoundation




/*
class FairplayPlayer: AVPlayer , PageProtocol{
    private var loaderQueue = DispatchQueue(label: "CustomAssetPlayer")
    private var m3u8URL: URL
    private var delegate: FairplayResourceLoader? = nil
    
    init?(m3u8URL: URL, playerDelegate:CustomAssetPlayerDelegate? = nil, assetInfo:AssetPlayerInfo? = nil, drm:FairPlayDrm?) {
       
        self.m3u8URL = m3u8URL
        super.init()
        if let drm = drm  {
            self.delegate = FairplayResourceLoader(m3u8URL: m3u8URL, playerDelegate: playerDelegate, assetInfo:  assetInfo, drm: drm)
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
       
        let asset = AVURLAsset(url: self.m3u8URL)
        if let delegate = self.delegate {
            asset.resourceLoader.setDelegate(delegate, queue: loaderQueue)
        }
        let playerItem = AVPlayerItem(asset: asset)
        self.replaceCurrentItem(with: playerItem)
    }
    
    
    
    func getCertificateData(drm:FairPlayDrm, delegate: CustomAssetPlayerDelegate? = nil)  {
        DataLog.d("getCertificateData", tag: self.tag)
        guard let url = URL(string:drm.certificateURL) else {
            DataLog.e("DRM: certificateData url error", tag: self.tag)
            delegate?.onAssetLoadError(.drm(.noCertificate))
            return
        }
        var certificateRequest = URLRequest(url: url)
        certificateRequest.httpMethod = "POST"
        let task = URLSession(configuration: URLSessionConfiguration.default).dataTask(with:certificateRequest) {
            [weak self] (data, response, error) in
            guard error == nil, let data = data else
            {
                DataLog.e("DRM: certificateData error", tag: self?.tag ?? "")
                delegate?.onAssetLoadError(.drm(.noCertificate))
                return
            }
            if let self = self {
                let cerData = data.base64EncodedString()
                DataLog.d("DRM: certificate data: \(String(describing: String(data: data, encoding: .utf8)))", tag: self.tag)
                DataLog.d("DRM: certificate " + cerData , tag: self.tag)
                drm.certificate = data
                self.playAsset(drm: drm)
            }
        }
        task.resume()
    }
    
}
*/
