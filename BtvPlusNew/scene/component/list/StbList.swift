//
//  ThemaList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import Combine
class StbData:InfinityData, ObservableObject{
    private(set) var image: String = Asset.noImg1_1
    private(set) var title: String? = nil
    private(set) var subTitle: String? = nil
     
    private(set) var macAddress:String? = nil
    private(set) var uiAppVer:String? = nil
    private(set) var adult:String? = nil
    private(set) var patchVer:String? = nil
    private(set) var agentVer:String? = nil
    private(set) var eros:String? = nil
    private(set) var stbid:String? = nil
    private(set) var stbName:String? = nil
    private(set) var restrictedAge:String? = nil
    private(set) var port:String? = nil
    private(set) var address:String? = nil
    private(set) var isAdultSafetyMode:Bool? = nil
    private(set) var terminateDate:String? = nil
    @Published var stbNickName:String? = nil
    func setData(data:MdnsDevice) -> StbData {
        macAddress = data.stb_mac_address
        uiAppVer = data.ui_app_ver
        adult = data.adult
        patchVer = data.stb_patch_ver
        agentVer = data.rcu_agent_ver
        eros = data.eros
        stbid = data.stbid
        stbName = data.stb_mac_view
        restrictedAge = data.restricted_age
        port = data.port
        address = data.address
        isAdultSafetyMode = data.isAdultSafetyMode
        
        title = data.stb_mac_view
        if let mac = data.stb_mac_address {
            subTitle = String.app.macAdress + " : " + mac
        }
        image = Pairing.getSTBImage(stbModel: data.stb_mac_view)
        return self
    }
    
    func setData(data:StbListInfoDataItem) -> StbData {
        macAddress = data.mac_address
        uiAppVer = ""
        adult = ""
        patchVer = ""
        agentVer = ""
        eros = ""
        stbid = data.stb_id
        stbName = data.model_name
        restrictedAge = ""
        port = ""
        address = ""
        isAdultSafetyMode = false
        terminateDate = data.svcTermDt
        title = data.model_name
        if let date = terminateDate {
            subTitle = String.pageText.terminateBtvDate + " : " + date
        } else if let mac = macAddress {
            subTitle = String.app.macAdress + " : " + mac
        }
        image = Pairing.getSTBImage(stbModel: data.model_name)
        return self
    }
    
    func setData(data:HostNickName) {
        guard let find = data.stbList?.first(where: {$0.joined_stb_id == self.stbid}) else {return}
        self.stbNickName = find.joined_nickname
      
    }
    
    func setDummy() -> StbData {
        title = "BHX-UX400"
        subTitle = "MAC 주소 : 00:00:00:00:00:00"
        return self
    }
}

struct StbList: PageComponent{
    var datas:[StbData]
    let action: (_ data:StbData) -> Void
    var body: some View {
        VStack (alignment: .leading, spacing: 0){
            ForEach(self.datas) { data in
                StbItem( data: data)
                .accessibility(label: Text(data.title ?? ""))
                .onTapGesture {
                    self.action(data)
                }
                    
            }
        }
        
    }//body
}

struct StbItem: PageView {
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var data:StbData
    @State var nickName:String? = nil
    var body: some View {
        VStack(alignment:.leading , spacing:0){
            HStack(spacing:Dimen.margin.light){
                Image(data.image)
                .renderingMode(.original)
                .resizable()
                .frame(
                    width: ListItem.stb.size.width,
                    height: ListItem.stb.size.height)
                VStack( alignment:.leading , spacing:Dimen.margin.tiny){
                    if let nick = self.nickName {
                        Text(nick + "(" + String.app.defaultStb + ")")
                            .modifier(MediumTextStyle(size: Font.size.regular))
                    }else {
                        Text(String.app.defaultStb)
                            .modifier(MediumTextStyle(size: Font.size.regular))
                    }
                    if self.data.subTitle != nil {
                        Text(self.data.subTitle!)
                            .modifier(MediumTextStyle(
                                        size: Font.size.thin, color: Color.app.grey))
                    }
                }
            }
            .padding(.all, Dimen.margin.light)
            Spacer()
                .modifier(MatchHorizontal(height: 1))
                .background(Color.app.greyExtra)
                .opacity(0.1)
        }
        
        .onReceive(self.data.$stbNickName){ nick in
            self.nickName = nick
        }
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            if !res.id.hasPrefix(self.data.stbid ?? "") {return}
            switch res.type {
            case .getHostNickname :
                guard let data = res.data as? HostNickName else { return }
                self.data.setData(data: data)
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
        guard let stbid = self.data.stbid else {return}
        self.searcher?.cancel()
        self.searcher = Timer.publish(
            every: 0.3, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.searcher?.cancel()
                self.searcher = nil
                self.dataProvider.requestData(
                    q: .init(id: stbid,
                        type: .getHostNickname(isAll:false, anotherStbId:stbid), isOptional: true))
            }
    }
}

#if DEBUG
struct StbList_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            StbList(
                datas: [
                    StbData().setDummy(),
                    StbData().setDummy(),
                    StbData().setDummy(),
                    StbData().setDummy(),
                    StbData().setDummy()
                ]
            ){_ in
                
            }
            .frame(width:320,height:600)
        }
        .background(Color.brand.bg)
    }
}
#endif
