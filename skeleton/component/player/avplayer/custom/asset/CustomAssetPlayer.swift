import Foundation
import AVFoundation




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
        /*
        let customScheme = CustomAssetResourceLoader.scheme
        guard let customURL = drm != nil
                ? replaceURLWithScheme(customScheme,url: m3u8URL)
                : m3u8URL
        else { return }
        */
        let customURL = m3u8URL
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
            let drmError:DRMError = .certificate(reason: "certificateData url error")
            DataLog.e(drmError.getDescription(), tag: self.tag)
            delegate?.onAssetLoadError(.drm(drmError))
            return
        }
        var certificateRequest = URLRequest(url: url)
        certificateRequest.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with:certificateRequest) {
            [weak self] (data, response, error) in
            if let self = self {
                guard let data = data else
                {
                    let reason = error == nil ? "no certificateData" : error!.localizedDescription
                    let drmError:DRMError = .certificate(reason: reason)
                    DataLog.e(drmError.getDescription(), tag: self.tag)
                    delegate?.onAssetLoadError(.drm(drmError))
                    return
                }
                drm.certificate =  data
                //let str = String(decoding: data, as: UTF8.self)
                DataLog.d("certificate success" , tag: self.tag)
                self.playAsset(drm: drm)
            }
        }
        task.resume()
    }
    
}
