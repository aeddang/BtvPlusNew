//
//  ThemaList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import Combine
class UserData:InfinityData, ObservableObject{
    private(set) var image: String = Asset.noImg1_1
    private(set) var title: String? = nil
    private(set) var joinDate:String? = nil
    private(set) var joinId:String = UUID().uuidString
    
    func setDummy() -> UserData {
        title = String.oksusu.connectJoinFb
        joinDate = String.oksusu.connectJoinDate + "2017.09.01"
        return self
    }
}

struct UserList: PageComponent{
    var datas:[UserData]
    let action: (_ data:UserData) -> Void
    var body: some View {
        VStack (alignment: .leading, spacing: 0){
            ForEach(self.datas) { data in
                UserItem( data: data)
                .onTapGesture {
                    self.action(data)
                }
                    
            }
        }
    }//body
}

struct UserItem: PageView {
    @ObservedObject var data:UserData
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
                    if let title = self.data.title {
                        Text(title)
                            .modifier(MediumTextStyle(size: Font.size.regular))
                    }
                    if let joinDate = self.data.joinDate {
                        Text(joinDate)
                            .modifier(MediumTextStyle(size: Font.size.thin, color: Color.app.grey))
                    }
                }
            }
            .padding(.all, Dimen.margin.light)
            Spacer()
                .modifier(MatchHorizontal(height: 1))
                .background(Color.app.greyExtra)
                .opacity(0.1)
        }
    }
    
}

#if DEBUG
struct UserList_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            UserList(
                datas: [
                    UserData().setDummy(),
                    UserData().setDummy(),
                    UserData().setDummy(),
                    UserData().setDummy(),
                    UserData().setDummy()
                ]
            ){_ in
                
            }
            .frame(width:320,height:600)
        }
        .background(Color.brand.bg)
    }
}
#endif
