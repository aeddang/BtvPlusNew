//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI

struct PageHome: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PageDataProviderModel = PageDataProviderModel()
   
    
    var body: some View {
        PageDataProviderContent(
            pageObservable:self.pageObservable,
            viewModel : self.viewModel
        ){
            VStack(alignment: .center)
            {
                Spacer()
            }//VStack
           // .modifier(MatchParent())
            .background(Color.app.white)
        }
        .onAppear{
            //self.viewModel.initate()
        }
        .onReceive(self.viewModel.$event){ evt in
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
        
    }//body
    
}


#if DEBUG
struct PageHome_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageHome().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

