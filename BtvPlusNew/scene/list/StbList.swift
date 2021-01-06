//
//  ThemaList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

class StbData:InfinityData{
    private(set) var image: String = Asset.noImg1_1
    private(set) var title: String? = nil
    private(set) var subTitle: String? = nil
    
    func setData(data:MdnsDevice) -> StbData {
        title = data.stb_mac_view
        if let mac = data.stb_mac_address {
            subTitle = String.app.macAdress + " : " + mac
        }
        image = Pairing.getSTBImage(stbModel: data.stb_mac_view)
        return self
    }
    
    func setDummy() -> StbData {
        title = "BHX-UX400"
        subTitle = "MAC 주소 : 00:00:00:00:00:00"
        return self
    }
}

struct StbList: PageComponent{
    @Binding var datas:[StbData]
    let action: (_ data:StbData) -> Void
    var body: some View {
        VStack (alignment: .leading, spacing: 0){
            ForEach(self.datas) { data in
                StbItem( data: data)
                .onTapGesture {
                    self.action(data)
                }
                    
            }
        }
        
    }//body
}

struct StbItem: PageView {
    var data:StbData
    var body: some View {
        VStack(alignment:.leading , spacing:0){
            HStack(spacing:Dimen.margin.light){
                Image(data.image)
                .renderingMode(.original)
                .resizable()
                .frame(
                    width: ListItem.stb.size.width,
                    height: ListItem.stb.size.height)
                VStack( alignment:.leading , spacing:0){
                    if self.data.title != nil {
                        Text(self.data.title!)
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
            Spacer().modifier(MatchHorizontal(height: 1)).background(Color.app.greyExtra)
        }
    
    }
}

#if DEBUG
struct StbList_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            StbList(
                datas: .constant([
                    StbData().setDummy(),
                    StbData().setDummy(),
                    StbData().setDummy(),
                    StbData().setDummy(),
                    StbData().setDummy()
                ])
            ){_ in
                
            }
            .frame(width:320,height:600)
        }
        .background(Color.brand.bg)
    }
}
#endif
