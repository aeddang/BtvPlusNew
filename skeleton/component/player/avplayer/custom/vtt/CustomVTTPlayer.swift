import Foundation
import AVFoundation

class CustomVTTPlayer: AVPlayer, PageProtocol {
    private var loaderQueue = DispatchQueue(label: "CustomVTTPlayer")
    private var m3u8URL: URL
    private var delegate: CustomVTTResourceLoader
    
    init?(m3u8URL: URL, vttURL: URL) {
        self.m3u8URL = m3u8URL
        self.delegate = CustomVTTResourceLoader(m3u8URL: m3u8URL,
                                                     vttURL: vttURL)
        super.init()
        let customScheme = CustomVTTResourceLoader.mainScheme
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
        let urlString = url.absoluteString
        guard let index = urlString.firstIndex(of: ":") else { return nil }
        let rest = urlString[index...]
        let newUrlString = scheme + rest
        return URL(string: newUrlString)
    }
    
}
