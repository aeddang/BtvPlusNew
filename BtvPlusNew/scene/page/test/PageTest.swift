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

struct PageTest: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appObserver:AppObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var playerModel = PlayerModel(path: "3qOhAhik0hA")
    @ObservedObject var naviModel = NavigationModel()
    @ObservedObject var webViewModel = WebViewModel(base: "https://www.todaypp.com")
    @State var naviImg:String? = Asset.brand.logoLauncher
    @State var index: Int = 0
    @State private var showingAlert = false
    @State private var showingMsg = ""
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center)
            {
                Spacer()
            }//VStack
            .padding([.bottom], Dimen.margin.heavy)
            .background(Color.app.white)
        }//GeometryReader
        .onAppear{
            self.webViewModel.request = .home
            //self.playerModel.event = PlayerUIEvent.load(testPath, false, 0.0)
            //self.playerModel.event = PlayerUIEvent.resume
            // SocialMediaSharingManage.share(SocialMediaShareable(text:"sjdhdsaijhancfk"))
            PageLog.d(self.pageObject.debugDescription, tag: self.tag)
            /*
            guard let qurry = WhereverYouCanGo.qurryIwillGo(
                pageID: .test,
                params: ["a": true ],
                isPopup: true,
                pageIDX: 999) else { return }
            let linkBuilder = DynamicLinkMamager.getDynamicLinkSocialBuilder(qurry:qurry)
            linkBuilder?.shorten() { url, warnings, error in
                guard let url = url else { return }
                SocialMediaSharingManage.share(SocialMediaShareable(url:url))
               // WhereverYouCanGo.parseIwillGo(qurryString: qurry)
            }
            */
             
        }.onReceive(self.appObserver.$page){ page in
            guard let go = page else {return}
            self.showingAlert = true
            self.showingMsg = go.page?.pageID ?? "no page id"
        }
        /*
        .onReceive(self.dataProvider.bands.$event){ evt in
            guard let evt = evt else { return }
            switch evt {
            case .willRequest(let progress):
                switch progress {
                case 0 : self.viewModel.requestProgress(qs: [.init(type: .getGnb),.init(type: .getGnb)])
                case 1 : self.viewModel.requestProgress(q: .init(type: .getGnb))
                case 2 : self.viewModel.requestProgress(q: .init(type: .getGnb))
                case 3 : self.viewModel.requestProgress(q: .init(type: .getGnb))
                default : do{}
                }
            case .onResult(let progress, let res, let count):
                PageLog.d("success progress : " + progress.description + " count: " + count.description, tag: self.tag)
            
            case .onError(let progress,  let err, let count):
                PageLog.d("error progress : " + progress.description + " count: " + count.description, tag: self.tag)
            default: do{}
            }
        }
        */
    
    }//body
    
    func onPageReload() {
        PageLog.log("PAGE  VIEW EVENT")
    }
    
}


#if DEBUG
struct PageTest_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageTest().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(Repository())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

