import Foundation
import SwiftUI

enum BannerType {
    case top, list, cell(CGSize, CGFloat)
    var size:CGSize {
        get{
            switch self {
            case .list: return ListItem.banner.type01
            case .cell(let size, _ ): return size
            case .top : return CGSize()
            }
        }
    }
}

class BannerData:InfinityData, PageProtocol{
    private(set) var image: String = Asset.noImgBanner
    private(set) var logo: String? = nil
    private(set) var focus: String? = nil
    private(set) var title: String? = nil
    private(set) var subTitle: String? = nil
    
    private(set) var outLink:String? = nil
    private(set) var inLink:String? = nil
    private(set) var move:PageID? = nil
    private(set) var moveData:[PageParam:Any]? = nil
    
    private(set) var type:BannerType = .list
    
    func setData(data:EventBannerItem, type: EuxpNetwork.BannerType = .list ,idx:Int = -1) -> BannerData {
        if let poster = data.bnr_off_img_path {
            switch type {
            case .list:
                image = ImagePath.thumbImagePath(filePath: poster, size: ListItem.banner.type01)  ?? image
                self.type = .list
                
            case .page:
                image = ImagePath.thumbImagePath(filePath: poster, size: CGSize(width: 0, height: TopBanner.imageHeight))  ?? image
                logo = ImagePath.thumbImagePath(filePath: data.logo_img_path, size: CGSize(width: 320, height: 0), convType: .alpha)
                focus = ImagePath.thumbImagePath(filePath: data.width_focus_off_path, size: CGSize(width: 320, height: 0))
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
                self.type = .top
            }
        }
       
        title = data.menu_nm
        index = idx
        parseAction(data: data)
        return self
    }
    
    func setBannerType(width:CGFloat, height:CGFloat, padding:CGFloat) -> BannerData {
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
                self.move = PageID.home
                let gnbTypeCd: String = arrParam[0]
                var param = [PageParam:Any]()
                param[.id] = gnbTypeCd
                if arrParam.count > 2 {
                    let subMenu: String = arrParam[2]
                    let url = arrParam[1] + "/" + subMenu.replace( "|", with: "/")
                    DataLog.d("page link " + url, tag:self.tag)
                }
                self.moveData = param
                
            }
        case "503":
            self.move = PageID.synopsis
            // 503 시놉 바로가기
            // 1. "call_typ_cd": "503"이면
            // 2. synon_typ_cd로 시놉시스 유형을 판단한 후
            // 3. EUXP-010 조회
            // A. 단, 조회 시에 sris_id  -> shcut_sris_id, epsd_id  -> shcut_epsd_id 사용
            // synon_typ_cd : 타이틀01/시즌02/콘텐츠팩03/관련상품팩04/전시용콘텐츠팩05 <- 모바일 기준으로는 01, 02, 03만 사용
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
