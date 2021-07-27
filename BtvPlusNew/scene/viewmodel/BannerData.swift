import Foundation
import SwiftUI

enum BannerType {
    case top, list, kids, cell(CGSize, CGFloat), horizontalList, leading
    var size:CGSize {
        get{
            switch self {
            case .list: return ListItem.banner.type01
            case .kids: return ListItemKids.banner.type01
            case .cell(let size, _ ): return size
            case .horizontalList : return ListItem.banner.type04
            default : return CGSize()
            }
        }
    }
    var radius:CGFloat {
        get{
            switch self {
            case .kids: return DimenKids.radius.light
            default : return 0
            }
        }
    }
    
    var noImage:String {
        get{
            switch self {
            case .kids: return AssetKids.noImgBanner
            case .horizontalList:return  Asset.noImg1_1
            default : return  Asset.noImgBanner
            }
        }
    }
    
   
    
}

class BannerData:InfinityData, PageProtocol{
    private(set) var image: String = Asset.noImgBanner
    private(set) var resourceImage: String? = nil
    private(set) var logo: String? = nil
    private(set) var title: String? = nil
    private(set) var subTitle: String? = nil
    private(set) var outLink:String? = nil
    private(set) var inLink:String? = nil
    private(set) var move:PageID? = nil
    private(set) var moveData:[PageParam:Any]? = nil
    private(set) var bgColor:Color? = nil
    private(set) var type:BannerType = .list 
    func setPairing()-> BannerData {
        self.move = .pairing
        self.resourceImage = Asset.image.bannerTopPairing
        return self
    }
    
    func setDataKids(data:EventBannerItem) -> BannerData {
        self.type = .kids
        self.bgColor = Color.app.ivoryDeep
        image = ImagePath.thumbImagePath(filePath: data.bnr_off_img_path, size: ListItemKids.banner.type01)  ?? image
        title = data.menu_nm
        parseAction(data: data)
        return self
    }
    
    func setData(data:EventBannerItem, type: EuxpNetwork.BannerType = .list, cardType:BlockData.CardType? = nil,  isFloat:Bool = false ,idx:Int = -1) -> BannerData {
        switch type {
        case .list:
            if  cardType == .bigPoster {
                self.type = .leading
                image = ImagePath.thumbImagePath(filePath: data.bnr_off_img_path, size: ListItem.banner.type03)  ?? image
            } else {
                self.type = cardType == .bannerList ? .horizontalList : .list
                image = ImagePath.thumbImagePath(filePath: data.bnr_off_img_path, size:  self.type.size)  ?? image
            }
        
        case .page:
            if isFloat {
                image = ImagePath.thumbImagePath(filePath: data.bnr_off_img_path, size: CGSize(width: 240, height: 0))  ?? image
            } else{
                if SystemEnvironment.isTablet {
                    image = ImagePath.thumbImagePath(filePath: data.width_focus_off_path , size: CGSize(width: 480, height: 0))  ?? image
                } else {
                    image = ImagePath.thumbImagePath(filePath: data.bnr_off_img_path, size: CGSize(width: 240, height: 0))  ?? image
                }
                logo = ImagePath.thumbImagePath(filePath: data.logo_img_path, size: CGSize(width: 200, height: 0), convType: .alpha)
                
                if let str = data.bnr_img_expl {
                    subTitle = str.isEmpty ? nil : str
                }
                if let str = data.bnr_img_btm_expl , !str.isEmpty{
                    if subTitle == nil || subTitle?.isEmpty == true {
                        subTitle = str
                    }else{
                        subTitle! += ("\n" + str)
                    }
                }
                if let str = data.bnr_img_btm_expl2 , !str.isEmpty {
                    if subTitle == nil || subTitle?.isEmpty == true {
                        subTitle = str
                    }else{
                        subTitle! += ("\n" + str)
                    }
                }
            }
            self.type = .top
        }
            
        if let colorCode = data.img_bagr_color_code {
            bgColor = colorCode.toColor()
        }
        title = data.menu_nm
        index = idx
        parseAction(data: data)
        return self
    }
    
    @discardableResult
    func setBannerSize(width:CGFloat, height:CGFloat, padding:CGFloat) -> BannerData {
        self.type = .cell(CGSize(width: width, height: height), padding)
        return self
    }

    private func parseAction(data:EventBannerItem){
        guard let callTypeCd = data.call_typ_cd else { return }
        guard let callUrl = data.call_url else { return }
        
        switch callTypeCd {
        case "2":
            var url = callUrl
            if let range = callUrl.range(of: "outlink:", options: .caseInsensitive) {
                url.removeSubrange(range)
                self.outLink = url
            }
            if let range = callUrl.range(of: "inlink:", options: .caseInsensitive) {
                url.removeSubrange(range)
                if url.hasPrefix("http://") ||  url.hasPrefix("https://") {
                    self.inLink = url
                    return
                }
                self.move = PageProvider.getPageId(skimlink: url)
                if self.move == nil {
                    DataLog.d("unknown link " + url, tag:self.tag)
                }
            }
        case "501":
            let arrParam = callUrl.components(separatedBy: "/")
            if arrParam.count > 0 {
                
                let gnbTypeCd: String = arrParam[0]
                var subMenu: String? = nil
                var url: String? = nil
                var param = [PageParam:Any]()
                if arrParam.count > 2 {
                    subMenu = arrParam[2]
                    url = arrParam[1] + "/" + subMenu!.replace( "|", with: "/")
                    DataLog.d("page link " + url!, tag:self.tag)
                    
                }
                if gnbTypeCd == EuxpNetwork.GnbTypeCode.GNB_KIDS.rawValue {
                    self.move = PageID.kidsHome
                    param[.id] = subMenu
                    param[.link] = url
                   
                } else {
                    self.move = gnbTypeCd == EuxpNetwork.GnbTypeCode.GNB_CATEGORY.rawValue ? PageID.category : PageID.home
                    param[.id] = gnbTypeCd
                    param[.link] = url
                    param[.subId] = subMenu
                }
                self.moveData = param
                
            }
        case "503":
            let type = SynopsisType(value: data.synon_typ_cd)
            self.move = (type == .package) ? PageID.synopsisPackage : PageID.synopsis
            let synopsisData = SynopsisData(
                srisId: data.shcut_sris_id,
                searchType: data.synon_typ_cd,
                epsdId: data.shcut_epsd_id
            )
            var param = [PageParam:Any]()
            param[.data] = synopsisData
            self.moveData = param
            
        default:
            break
        }
        
    }
}
