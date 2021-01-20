//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI

struct PageServiceError: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PageDataProviderModel = PageDataProviderModel()
    
    @State var error:ApiResultError? = nil
    @State var redirectPage:PageID? = nil
    
    var body: some View {
        PageDataProviderContent(
            pageObservable:self.pageObservable,
            viewModel : self.viewModel
        ){
            VStack(alignment: .center, spacing: 0){
                Image(Asset.icon.alert)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Dimen.icon.heavy, height: Dimen.icon.heavy)
                Text(String.alert.serviceUnavailable)
                    .modifier(BoldTextStyle(size: Font.size.regular, color: Color.app.greyLight))
                    .padding(.top, Dimen.margin.medium)
                Text(String.alert.serviceUnavailableText1)
                    .modifier(MediumTextStyle(size: Font.size.lightExtra, color: Color.app.greyLight))
                    .padding(.top, Dimen.margin.regular)
                Text(String.alert.serviceUnavailableText2)
                    .modifier(MediumTextStyle(size: Font.size.lightExtra, color: Color.app.greyLight))
                    .padding(.top, Dimen.margin.tiny)
                if self.error != nil {
                    FillButton(
                        text: String.app.retry
                    ){_ in
                        self.viewModel.request = ApiQ(type:self.error!.type, isLock:true)
                    }
                    .padding(.horizontal, Dimen.margin.heavy)
                    .padding(.top, Dimen.margin.medium)
                }else{
                    FillButton(
                        text: String.app.retry
                    ){_ in
                        self.repository.retryRepository()
                    }
                    .padding(.horizontal, Dimen.margin.heavy)
                    .padding(.top, Dimen.margin.medium)
                }
            }
        }
        .modifier(PageFull())
        .onReceive(self.viewModel.$event ){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .onResult(_, _, _) :
                if self.redirectPage != nil {
                    self.pagePresenter.changePage(
                        PageProvider.getPageObject(self.redirectPage!)
                    )
                }
            default : do{}
            }
        }
        .onAppear{
            guard let obj = self.pageObject  else { return }
            DispatchQueue.main.async {
                self.redirectPage = obj.getParamValue(key: .id) as? PageID
                self.error = obj.getParamValue(key:.data) as? ApiResultError
            }
        }
        
        
    }//body
    
    
    
}


#if DEBUG
struct PageServiceError_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageServiceError().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(DataProvider())
                .environmentObject(Repository())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

