//
//  KidsHomeData.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/13.
//

import Foundation

class KidsHomeBlockData:Identifiable, ObservableObject{
    static let code = "03"
    let id:String = UUID().uuidString
    var datas:[KidsHomeBlockListData] = []
    
    func setData(data:BlockData) -> KidsHomeBlockData{
       
        data.blocks?.forEach{ block in
            if let svcPropCd = block.svc_prop_cd {
                switch svcPropCd {
                case KidsMyItemData.code :
                    self.datas.append(KidsMyItemData().setData(data: block))
                default :
                    self.datas.append(KidsCategoryItemData().setData(data: block))
                }
            } else {
                switch block.btm_bnr_blk_exps_cd {
                case "07", "08", "05" :
                    self.datas.append(KidsCategoryListData().setData(data: block, uiType: data.uiType))
                case KidsPlayListData.code :
                    self.datas.append(KidsPlayListData().setData(data: block))
                default :
                    if block.blk_typ_cd == "70" {
                        self.datas.append(KidsBannerData().setData(data: block))
                    }
                }
            }
        }
        
        return self
    }
}

enum KidsHomeBlockListType {
    case none, myHeader, playList, cateHeader, cateList, banner
}
    
open class KidsHomeBlockListData:Identifiable {
    public var id: String = UUID().uuidString
    var type:KidsHomeBlockListType = .none
}


