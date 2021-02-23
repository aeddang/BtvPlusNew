//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

class BannerData:InfinityData, PageProtocol{
    private(set) var image: String = Asset.noImg16_9
    private(set) var title: String? = nil
    private(set) var subTitle: String? = nil
    
    private(set) var link:String? = nil
    private(set) var move:PageID? = nil
    private(set) var moveData:[PageParam:Any]? = nil
     
    func setData(data:EventBannerItem, idx:Int = -1) -> BannerData {
        if let poster = data.bnr_off_img_path {
            image = ImagePath.thumbImagePath(filePath: poster, size: ListItem.banner.size)
        }
        title = data.menu_nm
        index = idx
        parseAction(data: data)
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
                self.link = url
            }
            if let range = callUrl.range(of: "inlink:", options: .caseInsensitive) {
                url.removeSubrange(range)
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

struct BannerItem: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    var data:BannerData
    var body: some View {
        ZStack{
            ImageView(url: self.data.image, contentMode: .fill, noImg: Asset.noImg16_9)
                .modifier(MatchParent())
        }
        .modifier(MatchHorizontal(height: ListItem.banner.size.height))
        .background(Color.app.blueLight)
        .clipped()
        .onTapGesture {
            if let move = data.move {
                switch move {
                case .home :
                    if let gnbTypCd = data.moveData?[PageParam.id] as? String {
                        if let band = dataProvider.bands.getData(gnbTypCd: gnbTypCd) {
                            self.pagePresenter.changePage(
                                PageProvider
                                    .getPageObject(move)
                                    .addParam(key: .id, value: band.menuId)
                                    .addParam(key: UUID().uuidString , value: "")
                            )
                        }
                    }
                    
                default :
                    let pageObj = PageProvider.getPageObject(move)
                    pageObj.params = data.moveData
                    self.pagePresenter.openPopup(pageObj)
                }
            }
            
        }
    }
}

#if DEBUG
struct BannerItem_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            BannerItem( data:
                BannerData())
            .environmentObject(PagePresenter()).modifier(MatchParent())
        }
    }
}
#endif

