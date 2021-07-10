//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct TabInfoData {
    let title:String
    let text:String
}

extension PageTabInfo{
    static let idealWidth:CGFloat = SystemEnvironment.isTablet ? 565: 326
    static let maxWidth:CGFloat = SystemEnvironment.isTablet ? 820 : 428
    static let tabWidth:CGFloat = SystemEnvironment.isTablet ? 219 : 123
}

struct PageTabInfo: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var tabNavigationModel:NavigationModel = NavigationModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    
    
    @State var datas:[TabInfoData] = []
    let maxTextCount:Int = SystemEnvironment.isTablet ? 400 : 200
    @State var text = ""
    @State var tabIdx:Int = 0
    @State var tabs:[String] = []
    var body: some View {
        ZStack{
            Button(action: {
                self.pagePresenter.closePopup(self.pageObject?.id)
            }) {
               Spacer().modifier(MatchParent())
                   .background(Color.transparent.black70)
            }
            VStack{
                VStack (alignment: .center, spacing:DimenKids.margin.regularExtra){
                    if !self.tabs.isEmpty {
                        if self.tabs.count > 3{
                            ZStack{
                                ScrollView(.horizontal, showsIndicators: false){
                                    MenuTab(
                                        viewModel: self.tabNavigationModel,
                                        buttons: self.tabs,
                                        selectedIdx: self.tabIdx,
                                        bgColor: Color.app.ivoryDeep,
                                        isDivision: false)
                                        .padding(.horizontal, DimenKids.margin.regular)
                                }
                                HStack(spacing:0){
                                    LinearGradient(
                                        gradient:Gradient(colors: [Color.kids.bg, Color.kids.bg.opacity(0)]),
                                        startPoint: .leading, endPoint: .trailing)
                                        .modifier(MatchVertical(width:DimenKids.margin.regular))
                                    Spacer()
                                    LinearGradient(
                                        gradient:Gradient(colors: [Color.kids.bg.opacity(0), Color.kids.bg]),
                                        startPoint: .leading, endPoint: .trailing)
                                        .modifier(MatchVertical(width:DimenKids.margin.regular))
                                }
                                .frame(height:SystemEnvironment.isTablet ? DimenKids.tab.thin : DimenKids.tab.light)
                            }
                        } else {
                            MenuTab(
                                viewModel: self.tabNavigationModel,
                                buttons: self.tabs,
                                selectedIdx: self.tabIdx,
                                bgColor: Color.app.ivoryDeep,
                                isDivision: true)
                                .frame(width: Self.tabWidth * CGFloat(self.tabs.count))
                        }
                        
                    }
                    
                    if self.text.count > self.maxTextCount {
                        ScrollView{
                            Text(self.text)
                                .multilineTextAlignment(.center)
                                .modifier(BoldTextStyleKids(size: Font.sizeKids.lightExtra, color: Color.app.brownLight))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                    } else {
                        Text(self.text)
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
                }
                .modifier(ContentBox())
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
            if let datas = obj.getParamValue(key: .datas) as? [TabInfoData] {
                self.datas = datas
            }
            self.tabs = self.datas.map{$0.title}
            if let idx = obj.getParamValue(key: .selected) as? Int {
                self.tabNavigationModel.index = idx
            }
        }
        .onReceive(self.tabNavigationModel.$index){ idx in
            if self.tabs.isEmpty {return}
            
            if idx >= self.tabs.count {return}
            withAnimation{
                self.tabIdx = idx
                self.text = self.datas[idx].text
            }
        }
        .onAppear{
        }
        .onDisappear{
            
        }
    }//body
}

#if DEBUG
struct PageTabInfo_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageTabInfo().contentBody
                .environmentObject(PagePresenter())
               
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
