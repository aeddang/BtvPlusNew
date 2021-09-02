//
//  PageTest.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import WebKit
import Combine
import Firebase

struct SampleVideos: Codable {
    var name: String?
    var samples: [SampleVideo]?
}
struct SampleVideo: Codable {
    var name: String?
    var contentId: String?
    var uri: String?
    var drm_scheme: String?
    var drm_license_url: String?
}

class VideoListData:InfinityData{
    var title:String = "sample"
    var subTitle:String = ""
    var ckcURL:String? = nil
    var contentId:String? = nil
    var videoPath:String = ""//"https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8"
    init(title:String) {
        self.title = title
    }
    func setData(_ data:SampleVideo) -> VideoListData {
        subTitle = data.name ?? ""
        ckcURL = data.drm_license_url?.isEmpty == false ? data.drm_license_url : nil
        contentId = data.contentId
        videoPath = data.uri ?? ""
        return self
    }
}

struct VideoListItem: PageView {
    var data:VideoListData

    var body: some View {
        VStack(spacing:Dimen.margin.thin){
            Text(data.title)
                .modifier(BoldTextStyle(size: Font.size.thinExtra, color: Color.app.grey))
                .lineLimit(1)
            Text(data.subTitle)
                .modifier(BoldTextStyle(size: Font.size.thinExtra))
                .lineLimit(1)
                
        }
        .padding(.all, Dimen.margin.tiny)
        .background(Color.app.blueDeep)
    }
}



struct PagePlayerTestList: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    @State var apiPath:String = "http://api.geonames.org/citiesJSON?north=44.1&south=-9.9&east=-22.4&west=55.2&lang=de&username=demo"
    @State var lists:[VideoListData] = []
    var body: some View {
        VStack(alignment: .center)
        {
            PageTab( isClose: true)
                .padding(.top, Dimen.margin.medium)
            InfinityScrollView(
                viewModel: self.viewModel,
                axes: .vertical,
                marginVertical: 0,
                marginHorizontal: 0,
                spacing: Dimen.margin.thin,
                useTracking: false
            ){
                ForEach(self.lists) { data in
                    VideoListItem( data:data )
                    .onTapGesture {
                        self.pagePresenter.onPageEvent(self.pageObject, event: .init(id:self.tag, type: .selected, data:data))
                        self.pagePresenter.closePopup(self.pageObject?.id)
                    }
                }
            }
        }//VStack
        .padding([.bottom], Dimen.margin.heavy)
        .modifier(PageFull())
        .onAppear{
            guard let obj = self.pageObject  else { return }
            if let apiPath = obj.getParamValue(key: .data) as? String {
                if !apiPath.isEmpty {
                    self.apiPath = apiPath
                    //load()
                    //return
                }
                
            }
            self.loadAsset()

        }
    
    }//body
    
    private func loadAsset(){
        let url = Bundle.main.url(forResource: "resource_fairplay", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let decoder = JSONDecoder()
        do {
            let sets = try decoder.decode([SampleVideos].self, from: data)
            sets.forEach{ sample in
                self.lists = sample.samples?.map{ VideoListData(title: sample.name ?? "").setData($0)} ?? []
            }
        } catch let e {
            PageLog.e("parse error " + e.localizedDescription, tag: self.tag)
        }
       
       
    }
    
    private func load(){
        let net = TestNetwork(enviroment: self.apiPath)
        let rest = TestRest(network: net)
        rest.getList(
            completion: {res in
                res.forEach{ sample in
                    self.lists = sample.samples?.map{ VideoListData(title: sample.name ?? "").setData($0)} ?? []
                }
            },
            error: {err in
                PageLog.e("error " + self.apiPath, tag: self.tag)
                self.appSceneObserver.event = .toast("API 형식이 다릅니다")
            }
        )
    }

    struct TestNetwork : Network{
        var enviroment: NetworkEnvironment
    }
    
    class TestRest: Rest{
        
        func getList(
            completion: @escaping ([SampleVideos]) -> Void, error: ((_ e:Error) -> Void)? = nil){
            fetch(route: TestRoute(), completion: completion, error:error)
        }
    }
    
    struct TestRoute:NetworkRoute{
        var method: HTTPMethod = .get
        var path: String = ""
    }
}


#if DEBUG
struct PagePlayerTestList_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePlayerTestList().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(Repository())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

