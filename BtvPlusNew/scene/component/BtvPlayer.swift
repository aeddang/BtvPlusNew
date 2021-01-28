//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

enum BtvPlayType {
    case preview(String), ad, vod(String, String?)
    var type: String {
        switch self {
        default: return "V"
        }
    }
    var title: String {
        switch self {
        case .preview: return "예고편"
        case .vod( _ , let title): return title ?? ""
        default: return ""
        }
    }
    var cid: String {
        switch self {
        case .preview(let epsdRsluId): return epsdRsluId
        case .vod(let epsdRsluId , _): return epsdRsluId
        default: return ""
        }
    }
}

struct Quality {
    let name:String
    let path:String
    
}


class BtvPlayerModel:PlayerModel{
    @Published private(set) var currentQuality:Quality? = nil
    private(set) var qualitys:[Quality] = []
    private(set) var header:[String:String]? = nil
    private func appendQuality(name:String, path:String){
        let quality = Quality(name: name, path: path)
        qualitys.append(quality)
    }
    
    func setData(data:PlayInfo, type:BtvPlayType) {
        var header = [String:String]()
        header["x-ids-cinfo"] = type.type + "," + type.cid + "," + type.title
        self.header = header
        
        self.qualitys = []
        self.currentQuality = nil
        if let auto = data.CNT_URL_NS_AUTO { self.appendQuality(name: "AUTO", path: auto) }
        if let fhd = data.CNT_URL_NS_FHD { self.appendQuality(name: "FHD", path: fhd) }
        if let hd = data.CNT_URL_NS_HD  { self.appendQuality(name: "HD", path: hd) }
        if let sd = data.CNT_URL_NS_SD  { self.appendQuality(name: "SD", path: sd) }
        if !qualitys.isEmpty {
            currentQuality = qualitys.first{$0.name == "HD"}
        }
    }

}

struct BtvPlayer: PageComponent{
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var viewModel: BtvPlayerModel = BtvPlayerModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    var body: some View {
        ZStack{
            CPPlayer(viewModel:self.viewModel, pageObservable:self.pageObservable)
                .modifier(MatchParent())
            
        }
        .modifier(MatchParent())
        .onReceive(self.viewModel.$currentQuality){ quality in
            guard let quality = quality else {
                self.viewModel.event = .stop
                return
            }
            let find = quality.path.contains("?")
            let leading = find ? "&" : "?"
            let path = quality.path + leading +
                "device_id" + SystemEnvironment.getGuestDeviceId() +
                "&token=" + (repository.getDrmId() ?? "")
            ComponentLog.d("path : " + path, tag: self.tag)
            
            self.viewModel.event = .load(path, true, self.viewModel.time, self.viewModel.header)
        }
        
    }//body
}


#if DEBUG
struct BtvPlayer_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            BtvPlayer()
            .environmentObject(PagePresenter())
            .environmentObject(Pairing())
            .modifier(MatchParent())
        }
    }
}
#endif

