import Foundation
import SwiftUI

enum BannerType {
    case top, list, kids, horizontalList, cell(CGSize, CGFloat), cellKids(CGSize, CGFloat)
    var size:CGSize {
        get{
            switch self {
            case .list: return ListItem.banner.type01
            case .kids: return ListItemKids.banner.type01
            case .cell(let size, _ ): return size
            case .cellKids(let size, _ ): return size
            case .horizontalList : return ListItem.banner.type04
            default : return CGSize()
            }
        }
    }
    var radius:CGFloat {
        get{
            
            switch self {
            case .cellKids : return DimenKids.radius.light
            case .kids: return DimenKids.radius.light
            default : return 0
            }
        }
    }
    
    var noImage:String {
        get{
            switch self {
            case .cellKids : return AssetKids.noImg16_9
            case .kids: return AssetKids.noImgBanner
            case .horizontalList:return  Asset.noImg4_3
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
    private(set) var outLink:String? = nil
    private(set) var inLink:String? = nil
    private(set) var movePageType:PageType = .btv
    private(set) var move:PageID? = nil
    private(set) var moveData:[PageParam:Any]? = nil
    private(set) var bgColor:Color? = nil
    
    private(set) var subTitle1: String? = nil
    private(set) var subTitleColor1:Color = Color.app.grey
    
    private(set) var subTitle2: String? = nil
    private(set) var subTitleColor2:Color = Color.app.grey
    
    private(set) var subTitle3: String? = nil
    private(set) var subTitleColor3:Color = Color.app.grey
    private(set) var pageType:PageType = .btv
    private(set) var type:BannerType = .list
    
    private(set) var menuId:String? = nil
    private(set) var menuNm:String? = nil
    
    init(pageType:PageType = .btv) {
        self.pageType = pageType
        super.init()
    }
    
    func setPairing()-> BannerData {
        self.move = .pairing
        self.resourceImage = Asset.image.bannerTopPairing
        return self
    }
    
    func setDataKids(data:EventBannerItem) -> BannerData {
        self.type = .kids
        self.bgColor = Color.app.ivoryDeep
        self.menuId = data.menu_id
        self.menuNm = data.menu_nm
        image = ImagePath.thumbImagePath(filePath: data.bnr_off_img_path, size: ListItemKids.banner.type01)  ?? image
        title = data.menu_nm
        parseAction(data: data)
        return self
    }
    
    func setData(callUrl:String) -> BannerData {
        self.parseAction(callUrl: callUrl)
        return self
    }
    
    func setData(data:EventBannerItem, type: EuxpNetwork.BannerType = .list, cardType:BlockData.CardType? = nil,  isFloat:Bool = false ,idx:Int = -1) -> BannerData {
        self.menuId = data.menu_id
        self.menuNm = data.menu_nm
        switch type {
        case .list:
            if  cardType == .bigPoster {
                image = ImagePath.thumbImagePath(filePath: data.bnr_off_img_path, size: ListItem.banner.type03)  ?? image
            } else {
                self.type = cardType == .bannerList
                    ? .horizontalList
                    : .list
                image = ImagePath.thumbImagePath(filePath: data.bnr_off_img_path, size:  self.type.size)  ?? image
            }
        
        case .page:
            if isFloat {
                image = ImagePath.thumbImagePath(filePath: data.bnr_off_img_path, size: CGSize(width: 240, height: 0))  ?? image
            } else{
                if SystemEnvironment.isTablet {
                    image = ImagePath.thumbImagePath(filePath: data.width_focus_off_path , size: CGSize(width: 640, height: 0))  ?? image
                } else {
                    image = ImagePath.thumbImagePath(filePath: data.bnr_off_img_path, size: CGSize(width: 360, height: 0))  ?? image
                }
                logo = ImagePath.thumbImagePath(filePath: data.logo_img_path, size: CGSize(width: 200, height: 0), convType: .alpha)
                
                if let str = data.bnr_img_expl {
                    subTitle1 = str.isEmpty ? nil : str
                    subTitleColor1 = getExplainTextColor(data.bnr_img_expl_typ_cd)
                }
                if let str = data.bnr_img_btm_expl , !str.isEmpty{
                    subTitle2 = str.isEmpty ? nil : str
                    subTitleColor2 = getExplainTextColor(data.bnr_img_btm_expl_typ_cd)
                }
                if let str = data.bnr_img_btm_expl2 , !str.isEmpty {
                    subTitle3 = str.isEmpty ? nil : str
                    subTitleColor3 = getExplainTextColor(data.bnr_img_btm_expl_typ_cd2) 
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
    
    func getExplainTextColor(_ explainType: String?) -> Color{
        guard let type = explainType else {
            return Color.app.grey
        }
        switch type {
        case "03": return Color.brand.primary
        case "04" : return Color.app.brownExtra
        default: return  Color.app.greyLight
        }
    }
    
    @discardableResult
    func setBannerSize(width:CGFloat, height:CGFloat, padding:CGFloat) -> BannerData {
        self.type = self.pageType == .kids
            ? .cellKids(CGSize(width: width, height: height), padding)
            : .cell(CGSize(width: width, height: height), padding)
        return self
    }
    private func parseAction(callUrl:String){
        var url = callUrl
        if let range = callUrl.range(of: "outlink:", options: .caseInsensitive) {
            url.removeSubrange(range)
            self.outLink = url
        }else if let range = callUrl.range(of: "inlink:", options: .caseInsensitive) {
            url.removeSubrange(range)
            if url.hasPrefix("http://") ||  url.hasPrefix("https://") {
                self.inLink = url
                if self.title == nil { self.title = "" }
                return
            }
            
            self.move = PageProvider.getPageId(skimlink: url)
            if self.move == nil {
                DataLog.d("unknown link " + url, tag:self.tag)
            }
        } else {
            if self.title == nil { self.title = "" }
            self.inLink = callUrl
        }
    }
    private func parseAction(data:EventBannerItem){
        guard let callTypeCd = data.call_typ_cd else { return }
        guard let callUrl = data.call_url else { return }
        switch callTypeCd {
        case "2":
            self.parseAction(callUrl: callUrl)
        case "501":
            let arrParam = callUrl.components(separatedBy: "/")
            if arrParam.count > 0 {
                let gnbTypeCd: String = arrParam[0]
                var param = [PageParam:Any]()
                if gnbTypeCd == EuxpNetwork.GnbTypeCode.GNB_KIDS.rawValue {
                    
                    var cid: String? = nil
                    var subMenu: String? = nil
                    if arrParam.count > 1 { cid = arrParam[1] }
                    if arrParam.count > 2 { subMenu = arrParam[2] }
                    if cid == EuxpNetwork.KidsGnbCd.monthlyTicket.rawValue {
                        self.move = PageID.kidsMonthly
                        param[.subId] = subMenu
                    } else {
                        
                        self.move = PageID.kidsHome
                        param[.cid] = cid
                        param[.subId] = subMenu
                    }
                    self.movePageType = .kids
                    
                } else {
                    let subMenu: String? = (arrParam.count > 2) ? arrParam[2] : nil
                    self.move = gnbTypeCd == EuxpNetwork.GnbTypeCode.GNB_CATEGORY.rawValue ? PageID.category : PageID.home
                    param[.id] = gnbTypeCd
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
                epsdId: data.shcut_epsd_id,
                synopType: type
            )
            var param = [PageParam:Any]()
            param[.data] = synopsisData
            self.moveData = param
            
        default:
            break
        }
        
    }
    
    static func move(pagePresenter:PagePresenter, dataProvider:DataProvider ,data:BannerData?) {
        guard let data = data else {
            ComponentLog.e("not found data", tag: "BannerDataMove")
            return
        }
        if let move = data.move {
            switch move {
            case .home, .category:
                if let gnbTypCd = data.moveData?[PageParam.id] as? String {
                    if let band = dataProvider.bands.getData(gnbTypCd: gnbTypCd) {
                        pagePresenter.changePage(
                            PageProvider
                                .getPageObject(move)
                                .addParam(params: data.moveData)
                                .addParam(key: .id, value: band.menuId)
                                .addParam(key: UUID().uuidString , value: "")
                        )
                    }
                }
            case .kidsHome:
                let pageObj = PageKidsProvider.getPageObject(move)
                pageObj.params = data.moveData
                pagePresenter.changePage(pageObj.addParam(key: UUID().uuidString , value: ""))
                
            default :
                if data.movePageType == .btv {
                    let pageObj = PageProvider.getPageObject(move)
                    pageObj.params = data.moveData
                    pagePresenter.openPopup(pageObj)
                } else {
                    let pageObj = PageKidsProvider.getPageObject(move)
                    pageObj.params = data.moveData
                    pagePresenter.openPopup(pageObj)
                }
            }
        }
        else if let link = data.outLink {
            AppUtil.openURL(link)
        }
        else if let link = data.inLink {
            pagePresenter.openPopup(
                PageProvider
                    .getPageObject(.webview)
                    .addParam(key: .data, value: link)
                    .addParam(key: .title , value: data.title)
            )
        }
    }
}
