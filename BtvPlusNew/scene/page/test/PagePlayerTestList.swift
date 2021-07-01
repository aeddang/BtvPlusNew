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

class VideoListData:InfinityData{
    var title:String = "sample"
    var ckcURL:String = ""
    var contentId:String = ""
    var videoPath:String = "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8"
    init(title:String) {
        self.title = title
    }
}

struct VideoListItem: PageView {
    var data:VideoListData

    var body: some View {
        VStack(spacing:Dimen.margin.thin){
            Text(data.title)
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
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    @State var apiPath:String = "http://api.geonames.org/citiesJSON?north=44.1&south=-9.9&east=-22.4&west=55.2&lang=de&username=demo"
    @State var lists:[VideoListData] = [
        VideoListData(title: "sample1"),
        VideoListData(title: "sample2"),
        VideoListData(title: "sample3"),
        VideoListData(title: "sample4"),
        VideoListData(title: "sample5"),
        VideoListData(title: "sample6"),
        VideoListData(title: "sample7"),
        VideoListData(title: "sample8"),
        VideoListData(title: "sample9"),
        VideoListData(title: "sample10"),
        VideoListData(title: "sample11"),
        VideoListData(title: "sample1"),
        VideoListData(title: "sample2"),
        VideoListData(title: "sample3"),
        VideoListData(title: "sample4"),
        VideoListData(title: "sample5"),
        VideoListData(title: "sample6"),
        VideoListData(title: "sample7"),
        VideoListData(title: "sample8"),
        VideoListData(title: "sample9"),
        VideoListData(title: "sample10"),
        VideoListData(title: "sample11")
    ]
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
                load()
            }
           
            //
        }
    
    }//body
    
    private func load(){
        let net = TestNetwork(enviroment: self.apiPath)
        let rest = TestRest(network: net)
        rest.getList(
            completion: {res in
                PageLog.d(res.debugDescription, tag: self.tag)
            },
            error: {err in
                PageLog.e("error " + self.apiPath, tag: self.tag)
            }
        )
    }

    struct TestNetwork : Network{
        var enviroment: NetworkEnvironment
    }
    
    class TestRest: Rest{
        
        func getList(
            completion: @escaping ([String:Any]) -> Void, error: ((_ e:Error) -> Void)? = nil){
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

