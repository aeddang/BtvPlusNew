//
//  ThemaList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import struct Kingfisher.KFImage


class PeopleData:InfinityData{
    private(set) var image: String = Asset.noImg1_1
    private(set) var name: String? = nil
    private(set) var role:RoleType = .unknown
    private(set) var description: String? = nil
    private(set) var prsId: String? = nil
    private(set) var epsdId: String? = nil
    func setData(data:PeoplesItem, epsdId: String?, idx:Int = -1) -> PeopleData {
        name = data.prs_nm
        prsId = data.prs_id
        self.epsdId = epsdId
        role = RoleType.getType(data.prs_role_cd)
        switch role {
        case .director, .author, .step:
            description = data.prs_role_nm
        default:
            description = data.prs_plrl_nm
        }
        if let thumb = data.img_path {
            image = ImagePath.thumbImagePath(filePath: thumb, size: ListItem.people.size) ?? image
        }
        index = idx
        return self
    }
    func setDummy(_ idx:Int = -1) -> PeopleData {
        name = "우민호"
        description = "감독(연출)"
        role = .director
        index = idx
        return self
    }
}

enum RoleType {
    case director,step, author, voice, performer, guest, main, sub ,special, unknown
    static func getType(_ value:String?)->RoleType{
        switch value {
            case "00": return .director
            case "01": return .main
            case "02": return .sub
            case "03": return .special
            case "05": return .author
            case "10": return .performer
            case "09": return .guest
            case "07": return .step
            case "13": return .voice
            default : return .unknown
        }
        
    }
    func getColor()->Color{
        switch self {
        case .director, .author, .step:
            return Color.app.grey
        default : return Color.brand.primary
        }
    }
    func getDefaultImg()->String{
        switch self {
        case .director, .step: return Asset.image.noImgDirector
        case .author : return Asset.image.noImgWriter
        case .voice : return Asset.image.noImgVoice
        default : return Asset.image.noImgActor
        }
    }
}

extension PeopleList{
    static let height = ListItem.people.size.height
        + (Dimen.margin.micro + Dimen.margin.thin)
        + Font.size.lightExtra + Font.size.thinExtra + Dimen.margin.micro
}


struct PeopleList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[PeopleData]
    var useTracking:Bool = false
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .horizontal,
            marginVertical:0,
            marginHorizontal: Dimen.margin.thin ,
            spacing: Dimen.margin.thin,
            isRecycle: true,
            useTracking: self.useTracking
            ){
            
            ForEach(self.datas) { data in
                PeopleItem( data:data )
                .onTapGesture {
                    if data.epsdId == nil {return}
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.person)
                            .addParam(key: .data, value: data)
                    )
                }
            }
        }
    }//body
}

struct PeopleItem: PageView {
    var data:PeopleData
    
    var body: some View {
        VStack( spacing: 0 ){
            KFImage(URL(string: self.data.image))
                .resizable()
                .placeholder {
                    Image(self.data.role.getDefaultImg())
                        .resizable()
                }
                .cancelOnDisappear(true)
                .loadImmediately()
                .aspectRatio(contentMode: .fill)
                .frame(width: ListItem.people.size.width, height:ListItem.people.size.height)
                .clipShape(Circle())
                .padding(.bottom, Dimen.margin.thin)
            
            
            if self.data.name != nil {
                Text(self.data.name!)
                    .modifier(MediumTextStyle(
                        size: Font.size.lightExtra,
                        color: Color.app.whiteDeep))
                    .frame(width: ListItem.people.size.width)
                    .lineLimit(1)
                    .padding(.bottom, Dimen.margin.micro)
                    
            }
            if self.data.description != nil {
                Text(self.data.description!)
                    .modifier(MediumTextStyle(
                        size: Font.size.thinExtra,
                        color: self.data.role.getColor()
                    ))
                    .frame(width: ListItem.people.size.width)
                    .lineLimit(1)
                    
            }
        }
    }
}

#if DEBUG
struct PeopleList_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            PeopleList( datas: [
                PeopleData().setDummy(0),
                PeopleData().setDummy(),
                PeopleData().setDummy(),
                PeopleData().setDummy()
            ])
            .environmentObject(PagePresenter()).frame(width:320,height:600)
        }
    }
}
#endif
