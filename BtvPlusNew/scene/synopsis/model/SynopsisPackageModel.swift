//
//  SynopsisPackageModel.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/17.
//

import Foundation
class SynopsisPackageModel : PageProtocol {
   
    private(set) var packages:[PackageContentsItem] = []
    private(set) var posters:[PosterData] = []
    private(set) var image:String = Asset.noImg9_16
    private(set) var bg:String = Asset.noImg9_16
    private(set) var hasAuthority:Bool = false
    private(set) var distStsCd:DistStsCd = .synced
    private(set) var srisId:String? = nil
    private(set) var prdPrcId:String? = nil
    private(set) var salePrice: String? = nil
    private(set) var price: String? = nil
    private(set) var purchaseWebviewModel:PurchaseWebviewModel? = nil
    private(set) var contentMoreText:String = String.button.preview
    
    
    let type:PageType
    init(type:PageType = .btv) {
        self.type = type
    }
    
    func setData(data:GatewaySynopsis, isPosson:Bool, anotherStb:String?) -> SynopsisPackageModel {
        guard let contents = data.package else { return self}
        self.purchaseWebviewModel = PurchaseWebviewModel().setParam(data: data) 
        self.srisId = contents.sris_id
        self.prdPrcId = contents.prd_prc_id
        self.packages = contents.contents ?? []
        if self.type == .btv {
            self.image = ImagePath.thumbImagePath(filePath:  contents.mbtv_bg_img_path, size: CGSize(width: 0, height: TopViewer.height)) ?? image
            self.bg = ImagePath.thumbImagePath(filePath:  contents.mbtv_bg_img_path, size: CGSize(width: 0, height: TopViewer.height/2 ), convType: .blur) ?? bg
        } else {
            self.image = ImagePath.thumbImagePath(filePath:  contents.mbtv_bg_img_path_h, size: CGSize(width: 0, height: TopViewerKids.height)) ?? image
        }
        if let price = contents.sale_prc_vat {
            self.salePrice = price.formatted(style: .decimal) + String.app.cash
        }
        if let price = contents.prd_prc_vat {
            self.price = price.formatted(style: .decimal) + String.app.cash
            //(self.type == .btv ? price.currency : price.formatted(style: .decimal)) + String.app.cash
        }
        if let dist = DistStsCd(rawValue: contents.dist_sts_cd ?? "") {
            self.distStsCd = dist
        }
        self.posters = zip(0...self.packages.count, self.packages).map{ idx, d in
            PosterData(pageType: self.type).setData(data: d, prdPrcId: self.prdPrcId ?? "",
                                                    isPosson: isPosson, anotherStb : anotherStb,
                                                    idx: idx)
        }
        return self
    }
    
    func setData(data:DirectPackageView){
        self.hasAuthority = data.resp_directList?.first?.resp_direct_result?.toBool() ?? false
        self.contentMoreText = self.hasAuthority
            ? String.button.directview
            : self.prdPrcId?.isEmpty == false ? String.button.preview : String.button.detail 
    }


}
