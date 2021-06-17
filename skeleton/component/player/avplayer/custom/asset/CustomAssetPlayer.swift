import Foundation
import AVFoundation

class CustomAssetPlayer: AVPlayer , PageProtocol{
    private var loaderQueue = DispatchQueue(label: "CustomAssetPlayer")
    private var m3u8URL: URL
    private var delegate: CustomAssetResourceLoader
    
    init?(m3u8URL: URL) {
        self.m3u8URL = m3u8URL
        self.delegate = CustomAssetResourceLoader(m3u8URL:m3u8URL)
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
