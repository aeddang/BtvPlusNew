//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct DetailInfoData {
    var subTitle:String? = nil
    let title:String
    let text:String
}

extension PageDetailInfo{
    static let idealWidth:CGFloat = SystemEnvironment.isTablet ? 565: 326
    static let maxWidth:CGFloat = SystemEnvironment.isTablet ? 820 : 428
}

struct PageDetailInfo: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var tabNavigationModel:NavigationModel = NavigationModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    
    
    @State var data:DetailInfoData? = nil
    let maxTextCount:Int = 200
    
  
    var body: some View {
        ZStack{
            Button(action: {
                self.pagePresenter.closePopup(self.pageObject?.id)
            }) {
               Spacer().modifier(MatchParent())
                   .background(Color.transparent.black70)
            }
            VStack{
                if let data = self.data {
                    VStack (alignment: .center, spacing:0){
                        if let subTitle = data.subTitle {
                            Text(subTitle)
                                .multilineTextAlignment(.center)
                                .modifier(BoldTextStyleKids(size: Font.sizeKids.thinExtra, color: Color.app.brown))
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.bottom, DimenKids.margin.tiny)
                        }
                        Text(data.title)
                            .modifier(BoldTextStyleKids(size: Font.sizeKids.regular, color: Color.app.brown))
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer().modifier(LineHorizontal(color: Color.app.black))
                            .padding(.top, DimenKids.margin.tiny)
                            .padding(.bottom, DimenKids.margin.light)
                        if data.text.count > self.maxTextCount {
                            ScrollView{
                                Text(data.text)
                                    .multilineTextAlignment(.center)
                                    .modifier(BoldTextStyleKids(size: Font.sizeKids.lightExtra, color: Color.app.brownLight))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            
                        } else {
                            Text(data.text)
                                .multilineTextAlignment(.center)
                                .modifier(BoldTextStyleKids(size: Font.sizeKids.lightExtra, color: Color.app.brownLight))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        RectButtonKids(
                            text: String.app.corfirm,
                            isSelected: true
                        ){idx in
                            self.pagePresenter.closePopup(self.pageObject?.id)
                        }
                        .padding(.top, DimenKids.margin.mediumExtra)
                    }
                    .modifier(ContentBox())
                }
            }
            .frame(
                minWidth: 0,
                idealWidth: Self.idealWidth,
                maxWidth: Self.maxWidth,
                minHeight: 0,
                maxHeight:.infinity
            )
            .padding(.all, Dimen.margin.heavy)
        }
        .modifier(MatchParent())
        .onReceive(self.pageObservable.$isAnimationComplete){ ani in
            guard let obj = self.pageObject  else { return }
            if let data = obj.getParamValue(key: .data) as? DetailInfoData {
                self.data = data
            }
           
        }
        
        .onAppear{
        }
        .onDisappear{
            
        }
    }//body
}

#if DEBUG
struct PageDetailInfo_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageDetailInfo().contentBody
                .environmentObject(PagePresenter())
               
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
