//
//  HitchStbItem.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/27.
//

import Foundation
import SwiftUI
import Combine
struct HitchStbItem: PageView {
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var data:StbData
    @State var nickName:String? = nil
    var isSelected:Bool
    var body: some View {
        VStack(alignment:.center , spacing:SystemEnvironment.isTablet ? Dimen.margin.tinyExtra : Dimen.margin.tiny){
            Image(data.image)
            .renderingMode(.original)
            .resizable()
            .frame(
                width: SystemEnvironment.isTablet ? Dimen.icon.regular : Dimen.icon.medium,
                height: SystemEnvironment.isTablet ? Dimen.icon.regular : Dimen.icon.medium)
            
            if let nick = self.nickName {
                Text(nick)
                    .modifier(MediumTextStyle(
                                size: SystemEnvironment.isTablet ? Font.size.tinyExtra : Font.size.lightExtra,
                                color: Color.app.blackExtra))
                
            } else {
                Text(String.app.defaultStb)
                    .modifier(MediumTextStyle(
                                size: SystemEnvironment.isTablet ? Font.size.tinyExtra : Font.size.lightExtra,
                                color: Color.app.blackExtra))
            }
            
           
            if let macAddress = self.data.macAddress{
                Text(macAddress)
                    .modifier(MediumTextStyle(
                                size: SystemEnvironment.isTablet ? Font.size.micro : Font.size.tinyExtra,
                                color: Color.app.grey))
                    .lineLimit(1)
            }
        }
        .padding(.all, Dimen.margin.micro)
        .modifier(MatchParent())
        .background(self.isSelected ? Color.brand.primary.opacity(0.1) : Color.app.white)
        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.regularExtra))
        .overlay(
            RoundedRectangle(cornerRadius: Dimen.radius.regularExtra)
                .stroke( self.isSelected ? Color.brand.primary : Color.app.greyMedium ,lineWidth: self.isSelected ? 3 : 1 )
        )
        
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            if !res.id.hasPrefix(self.data.stbid ?? "") {return}
            switch res.type {
            case .getHostNickname :
                guard let data = res.data as? HostNickName else { return }
                self.data.setData(data: data)
                self.nickName = self.data.stbNickName
            default: break
            }
           
        }
        .onAppear(){
            if self.data.stbNickName == nil && self.data.stbid != nil{
                self.searchNickName()
            } else {
                self.nickName = self.data.stbNickName
            }
        }
        .onDisappear(){
            self.searcher?.cancel()
            self.searcher = nil
        }
    }
    
    @State private var searcher:AnyCancellable?
    private func searchNickName(){
        self.searcher?.cancel()
        self.searcher = Timer.publish(
            every: 0.3, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.searcher?.cancel()
                self.searcher = nil
                self.dataProvider.requestData(
                    q: .init(id: id,
                        type: .getHostNickname(isAll:false, anotherStbId:id), isOptional: true))
            }
    }
}
