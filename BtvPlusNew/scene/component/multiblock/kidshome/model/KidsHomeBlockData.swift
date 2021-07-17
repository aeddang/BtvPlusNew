//
//  KidsHomeData.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/13.
//

import Foundation

class KidsHomeBlockData:Identifiable, ObservableObject{
    let id:String = UUID().uuidString
    var datas:[KidsHomeBlockListData] = []
    
    func setData(data:BlockData) -> KidsHomeBlockData{
       
        data.blocks?.forEach{ data in
            if let svcPropCd = data.svc_prop_cd {
                switch svcPropCd {
                case "519" :
                    self.datas.append(KidsMyItemData().setData(data: data))
                default :
                    self.datas.append(KidsCategoryItemData().setData(data: data))
                }
            } else {
                switch data.btm_bnr_blk_exps_cd {
                case "07", "08", "05" :
                    self.datas.append(KidsCategoryListData().setData(data: data))
                case "09" :
                    self.datas.append(KidsPlayListData().setData(data: data))
                default :
                    if data.blk_typ_cd == "70" {
                        self.datas.append(KidsBannerData().setData(data: data))
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


