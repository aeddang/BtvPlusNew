//
//  SynopsisData.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/21.
//

import Foundation

struct SynopsisData {
    var srisId:String? = nil
    var searchType:String? = nil
    var epsdId:String? = nil
    var epsdRsluId:String? = nil
    var prdPrcId:String? = nil
    var kidZone:String? = nil
}

class SynopsisModel : PageProtocol {
    //지상파 월정액 복합 1476793, MBC ALL 복합 410705773, MBC + SBS 1210230 판매종료, MBC PLUS 월정액 410705797
    static let trstrsPidList = ["1476793", "410705773", "410705797", "1210230"] + singleTrstrsPidList
    //KBS 5430389, SBS, 4921402, MBC 5430512,
    static let singleTrstrsPidList = ["5430389", "4921402", "5430512"]
    
    private(set) var srisId:String? = nil
    private(set) var epsdId:String? = nil
    private(set) var epsdRsluId:String? = nil
    private(set) var srisTypCd:SrisTypCd = .none
    private(set) var isGstn = false
    private(set) var isPossonVODMode = false
    private(set) var isNScreen = false
    private(set) var isCombineProduct = false
    private(set) var rsluInfoList: Array< EpsdRsluInfo >? = nil
    private(set) var ppvProducts: Array< [String:String] > = []
    private(set) var ppsProducts: Array< [String:String] > = []
    private(set) var purchasModels: Array< PurchasModel > = []
    private(set) var synopsisType:MetvNetwork.SynopsisType
    private(set) var isEmptyProducts = false
    private(set) var distStsCd:DistStsCd = .synced
    private(set) var cacbroCd: CacbroCd = .none
    private(set) var isCancelProgram:Bool = false
    
    init(type:MetvNetwork.SynopsisType = .none ) {
        self.synopsisType = type
    }
    
    func setData(data:Synopsis) -> SynopsisModel {
        if synopsisType == .seasonFirst {
            if data.contents?.sris_typ_cd == EuxpNetwork.SrisTypCd.title.rawValue {
                self.synopsisType = .title
            }
        }
        self.srisId = data.contents?.sris_id
        if let contents = data.contents{
            self.isCombineProduct = contents.combine_product_yn?.toBool() ?? false
            self.epsdId = contents.epsd_id
            self.isGstn = contents.gstn_yn?.toBool() ?? false
            self.isNScreen = contents.nscrn_yn?.toBool() ?? false
            self.rsluInfoList = contents.epsd_rslu_info
            self.srisTypCd =  SrisTypCd(rawValue:contents.sris_typ_cd ?? "00") ?? .none
            self.isEmptyProducts = contents.products?.isEmpty ?? false
            if let dist = DistStsCd(rawValue: contents.dist_sts_cd ?? "") {
                self.distStsCd = dist
            }
            if contents.cacbro_yn?.toBool() == true {
                self.cacbroCd = CacbroCd(rawValue: contents.cacbro_cd ?? "" ) ?? .none
                self.isCancelProgram = !(contents.combine_product_yn?.toBool() == true && self.cacbroCd == .SS)
            }
            self.isDistProgram = self.distStsCd != .stop
        }
        
        //epsdRsluId
        if let products = data.contents?.products , let first = products.first(where: {$0.epsd_id == self.epsdId }) {
            self.epsdRsluId = first.epsd_rslu_id
        }
        if let purchares = data.purchares , let first = purchares.first(where: {$0.epsd_id == self.epsdId }) {
            self.epsdRsluId = first.epsd_rslu_id
        }
        if let first = data.contents?.epsd_rslu_info?.first {
            epsdRsluId = first.epsd_rslu_id
        }
        
        var productsPpv: Array< Dictionary<String, String> > = []
        var purchasPpv: Array< Dictionary<String, String> > = []
        if let products = data.contents?.products {
            productsPpv = products.map {  product in
                var set = Dictionary<String, String>()
                set["prd_prc_id"] = product.prd_prc_id
                set["epsd_id"] = product.epsd_id
                set["yn_prd_nscreen"] = data.contents?.nscrn_yn ?? "N"
                set["prd_typ_cd"] = product.prd_typ_cd
                set["purc_pref_rank"] = product.purc_pref_rank
                set["possn_yn"] = product.possn_yn
                return set
            }
            self.purchasModels.append(contentsOf: products.map { PurchasModel(product: $0)} )
        }
        
        if let purchares = data.purchares {
            purchasPpv = purchares.map { purchas in
                var set = Dictionary<String, String>()
                set["prd_prc_id"] = purchas.prd_prc_id
                set["epsd_id"] = purchas.epsd_id
                set["yn_prd_nscreen"] = data.contents?.nscrn_yn ?? "N"
                set["prd_typ_cd"] = purchas.prd_typ_cd
                set["purc_pref_rank"] = purchas.purc_pref_rank
                set["possn_yn"] = purchas.possn_yn
                return set
            }
            self.purchasModels.append(contentsOf: purchares.map { PurchasModel(purchas: $0)} )
        }
        
        if let contents = data.contents {
            zip(0...self.purchasModels.count,self.purchasModels).forEach({ idx,model in
                model.setupSynopsis(contents, idx: idx)
            })
        }
        
        switch self.synopsisType {
        case .seasonFirst :
            self.ppvProducts = productsPpv
            self.ppsProducts = purchasPpv
            
            var defaultSet = Dictionary<String, String>()
            defaultSet["prd_prc_id"] = "0"
            defaultSet["epsd_id"] = "0"
            defaultSet["yn_prd_nscreen"] = "N"
            defaultSet["prd_typ_cd"] = "10"
            defaultSet["purc_pref_rank"] = "0200"
            defaultSet["possn_yn"] = "N"
            
            if self.ppvProducts.count == 0 { self.ppvProducts.append(defaultSet) }
            if self.ppsProducts.count == 0 { self.ppsProducts.append(defaultSet) }
        case .seriesChange :
            self.ppvProducts = productsPpv
        case .title :
            self.ppvProducts = purchasPpv
        case .none: do{}
        }
        return self
    }
   
    private(set) var salePPMItem: PurchasModel? = nil
    private(set) var purchasedPPMItems: [PurchasModel] = []
    private(set) var purchasedPPSItems: [PurchasModel] = []
    private(set) var purchasableItems: [PurchasModel] = []
    private(set) var watchOptionItems: [PurchasModel]? = nil
    private(set) var curSynopsisItem: PurchasModel?
    private(set) var metvSeasonWatchAll:Bool = false
    private(set) var isPurchasableNextStep:Bool = false
    private(set) var isBookmark:Bool = false
    private(set) var isDistProgram:Bool = false
    
    var purchasedPid:String? = nil
    func setData(directViewdata:DirectView?){
        self.isBookmark = directViewdata?.is_bookmark?.toBool() ?? false
        self.metvSeasonWatchAll = directViewdata?.yn_season_watch_all?.toBool() ?? false
        self.purchasModels.forEach({ model in
            if let metvItem = directViewdata?.ppv_products?.first(where: {model.epsd_id == $0.epsd_id && model.prd_prc_id == $0.prd_prc_id}) {
                model.mePPVProduct = metvItem
            }
            if let metvItem = directViewdata?.pps_products?.first(where: {model.prd_prc_id == $0.prd_prc_id}) {
                model.mePPSProduct = metvItem
            }
            if model.prd_prc_id == purchasedPid && !model.isDirectview {
                model.forceModifyDirectview()
            }
            if let list = self.rsluInfoList , !list.isEmpty {
                if let rsluItem = list.first(where: { rsluItem in
                    let rsluTypCd = RsluTypCd(value: rsluItem.rslu_typ_cd ?? "")
                    return model.isPossn == rsluItem.possn_yn?.toBool()
                        && model.lag_capt_typ_cd == rsluItem.lag_capt_typ_cd
                        && model.rsluTypCd == rsluTypCd}
                ){
                    //핑크퐁 바다동물동요(product 없음, purchase pps만 있음)
                    if !model.epsd_rslu_id.isEmpty , rsluItem.epsd_rslu_id != nil && model.epsd_rslu_id != rsluItem.epsd_rslu_id {
                        //"해상도 아이디, epsd_rslu_info 동일한 타입과 다름. 재적용.")
                        model.forceModifyEpsdRsluId(rsluItem.epsd_rslu_id!)
                    }
                    if self.srisTypCd == .season {
                        if self.epsdId != nil && model.epsd_id != self.epsdId {
                            //"에피소드 아이디와 시놉시스 에피소드가 다름. 재적용.")
                            model.forceModifyEpsdId(self.epsdId!)
                        }
                    }
                
                } else if self.srisTypCd == .season, self.isEmptyProducts , let rsluItem = list.first {
                    //해상도 목록의 아이템과 같은 타입 못찾았을 때.
                    //플레이송스 productrs 없음, Purchase pps / pps 커머스 상품만 있음.
                    if !model.epsd_rslu_id.isEmpty, rsluItem.epsd_rslu_id != nil && model.epsd_rslu_id != rsluItem.epsd_rslu_id {
                        //"products 없음. 해상도 아이디, epsd_rslu_info 첫번째 아이템과 다름. 재적용."
                        model.forceModifyEpsdRsluId(rsluItem.epsd_rslu_id!)
                    }
                }
            }
        })
        
        let tempItems = self.purchasModels.filter({ $0.isRentPeriod || !($0.prdTypCd == .ppv && $0.rsluTypCd >= .uhd) })
        let usableItems = tempItems.count > 0 ? tempItems : self.purchasModels
        let purchasItems = usableItems.filter({ $0.isDirectview || $0.isUse && $0.isSalesPeriod }).sorted(by: { $0.prdPrcFrDt > $1.prdPrcFrDt })
        
        // 월정액(30)만 발라냄. 서버 오더링 사용. (첫번째 월정액 노출.)
        // 첫번째 월정액과 동일(prc_prc_id)한게 있다면 기존 복합ppm제외, 가격순, 최근날짜 로직 적용.
        var tempSalePPMItems = usableItems.filter({ PrdTypCd.vodppm == $0.prdTypCd && $0.isUse && $0.isSalesPeriod })
        if let first = tempSalePPMItems.first {
            self.salePPMItem = first
            //첫번째 아이템의 동일한 가격 상품 있나 찾음. (자기자신 포함.)
            tempSalePPMItems = tempSalePPMItems.filter({ first.sale_prc_vat == $0.sale_prc_vat })
            //같은가격 1개 이상일 경우 최신순.
            if tempSalePPMItems.count > 1 {
                tempSalePPMItems = tempSalePPMItems.sorted(by: {$0.prdPrcFrDt > $1.prdPrcFrDt})
                self.salePPMItem = tempSalePPMItems.count > 0 ? tempSalePPMItems.first : nil
            }
        } else {
            self.salePPMItem = nil
        }
        
        let ppmItems = usableItems.filter { PrdTypCd.isPPM(typCd: $0.prdTypCd, all: true) }
        let tempPurPPMItems = ppmItems.filter { $0.isDirectview }
        tempPurPPMItems.forEach { item in
            if !purchasedPPMItems.contains(where: { item.prd_prc_id == $0.prd_prc_id }) {
                purchasedPPMItems.append(item)
            }
        }
        purchasedPPMItems.sort(by: { $0.sale_prc_vat > $1.sale_prc_vat })
        let ppsItems = usableItems.filter { PrdTypCd.pps == $0.prdTypCd }
        let tempPurPpsItems = ppsItems.filter { $0.isDirectview || self.metvSeasonWatchAll }
        //pps 구매시 metv에서 모든 pps 권한 있다고 내려줘서 최신(최근판매시작) pps중, 소장 > 대여 우선순위로 구분.
        if let item = Dictionary(
            grouping: tempPurPpsItems,
            by: { $0.prdPrcFrDt }).sorted(by: { $0.key > $1.key }).first?.value.sorted(by: { $0.pssonRank > $1.pssonRank }).first,
            !self.purchasedPPSItems.contains(where: {$0.prd_prc_id == item.prd_prc_id}){
                self.purchasedPPSItems.append(item)
        }
        
        //단편 소장만 있는지 여부. 소장만 있으면 월정액 구매시 소장에 권한 부여. 아니면 대여에 권한 부여.
        let isOnlyPossonPPV = usableItems.filter({$0.prdTypCd == .ppv}).allSatisfy({$0.isPossn})
        if isPurchasedPPM {
            ppmItems.filter {
                let prdPrId = $0.prd_prc_id
                //더빙|대여 자막|대여 prc_prd_id 는 같은데 epsdId가 다름.
                return purchasedPPMItems.contains(where: { $0.prd_prc_id == prdPrId })
            }.forEach {
                if !$0.isDirectview {
                    $0.forceModifyDirectview()
                    //"상품 월정액 다른 타입 시청 가능 처리."
                }
            }
            //월정액 권한있는데 단편 권한 안줄경우 예외처리.(편성 오류 예외처리)
            //시리즈일 때 purchase ppm아이템에 에피소드랑 시놉시스의 에피소드랑 회차가 다를 수 있음. 최근날짜, 단편에 시청권한 부여.
            //월정액 구매했을 경우 단편 구매권한 y로 내려줌.
            //(200610기준 상용 프리미어 월정액 메뉴에 어벤져스 단편 자막|대여, 더빙|대여, 월정액 자막|대여, 더빙|대여 4개 권한 y내려줌)
            //월정액과 쌍을 맞춰서 권한 주는 것으로 보임.
            //월정액과 같은 타입에 권한 부여 (월정액은 대여만 내려오는 듯함.)
            //월정액, 자막|대여, 단편에 더빙|소장, 자막|소장만 있을경우..? 단편 다 권한x.
            //더빙|소장, 자막|대여 있을 경우..? 자막 대여만 권한 있음.
            //더빙|대여, 자막|소장 있을 경우, 단편 권한x.
             //현재 시놉의 ppm 아이템이 캐싱된 ppm 목록에 있고.(pid가 같다면), 단편에 권한 안내려줄 경우.
            if isPurchasedPPM, !usableItems.contains(where: { $0.prdTypCd == .ppv && $0.isDirectview }) {
                let temp = usableItems.filter({ $0.prdTypCd == .ppv && $0.isUse && $0.isSalesPeriod && !$0.isDirectview })
                purchasedPPMItems.forEach { ppmItem in
                if let target = temp.filter({ ppvItem in
                    ppmItem.lag_capt_typ_cd == ppvItem.lag_capt_typ_cd
                        && ppmItem.isPossn == ppvItem.isPossn
                        //월정액 해상도보다 같거나 작은 컨텐츠 권한 부여.
                        //타이틀 hd 구매하면 sd 권한 o, uhd 구매 hd, sd 권한 o 인듯
                        //시리즈 비밀의숲은 HD /UHD 별도인듯.
                        && ppmItem.rsluTypCd >= ppvItem.rsluTypCd})
                    .sorted(by: {$0.prdPrcFrDt > $1.prdPrcFrDt}).first {
                        target.forceModifyDirectview()
                        // "월정액 구매. 단편|\(isOnlyPossonPPV ? "소장" : "대여") 시청 가능 설정"
                    }
                }
            }
        }
        
        let containIsFree = purchasItems.contains(where: { $0.isFree })
        var tempUsableItems = usableItems
        if tempUsableItems.contains(where: {$0.prdTypCd == .ppv}) {
            tempUsableItems = tempUsableItems.filter { $0.prdTypCd == .ppv }
        }
        //pps/ppm 체크해서 권한 설정은 위에서 다 함. 시놉 에피가 아닌 것들 다지움.
        if self.srisTypCd == .season {
            tempUsableItems = tempUsableItems.filter {  $0.epsd_id == self.epsdId }
        }

        if let ppsItem = ppsItems.first(where: {
            let pid = $0.prd_prc_id
            return purchasedPPSItems.contains(where: { pid == $0.prd_prc_id }) }) {
            //회차변경으로 진입시 구매 yes처리.
            if !ppsItem.isDirectview {
                ppsItem.forceModifyDirectview()
                //"시리즈 구매. 회차 변경. pps 시청 가능 설정"
            }
            //더킹스페셜 pps구매상태인데 스페셜회차 단편이 없어서 위에 ppv 필터링에 안걸리고 모든 아이템 다 넘어와서
            //ppv 2차 체크.
            tempUsableItems.forEach {
                if !$0.isDirectview && $0.prdTypCd == .ppv {
                    if isOnlyPossonPPV && $0.isPossn {
                        $0.forceModifyDirectview()
                    } else if !$0.isPossn {
                        $0.forceModifyDirectview()
                    }
                    //"시리즈 구매. 단편 시청 가능 설정"
                }
            }
        }
        if tempUsableItems.contains(where: { $0.isDirectview }) {
            //권한 1개라도 가지고있으면 없는 애들 삭제.
            tempUsableItems.removeAll(where: { !$0.isDirectview })
        } else {
            //권한 없으면 판매가능, 판매기간 해당만 걸러냄.
            tempUsableItems.removeAll(where: { !$0.isUse || !$0.isSalesPeriod })
            //무료 있으면 무료만 사용.
            if containIsFree {
                tempUsableItems = tempUsableItems.filter({ $0.isFree })
            }
        }
        
        if isPossonVODMode {
            tempUsableItems = tempUsableItems.filter({ $0.isPossn && $0.epsd_id == self.epsdId })
        }
        var tempDic = Dictionary(grouping: tempUsableItems) { $0.epsd_id }
        //"자막/더빙/xx더빙 최신순 필터링")
        tempDic.forEach {
            //tempDic은 구매목록 or 미구매 목록만 넘어옴
            let isDirectview = $1.allSatisfy { $0.isDirectview }
            //let key = $0
            /*
            $1.forEach {
                SynopsisModel.printSynopItem(item: $0, preMsg: "선택 전 key: \(key)")
            }
            */
            //uhd 대여 상품 있는지 확인.(구매여부 & 대여기간 & 해상도체크)
            if let uhdRentItem = $1.filter({ $0.isPurchase && $0.isRentPeriod && $0.rsluTypCd == .uhd })
                .sorted(by: {$0.prdPrcFrDt > $1.prdPrcFrDt}).first {
                //"대여한 uhd key: \(key)"
                //같으 타입(자막,대여,소장)이면서 다른 해상도 찾음(보통 fhd.).
                if let item = $1.filter({ uhdRentItem.isPossn == $0.isPossn
                            && uhdRentItem.lag_capt_typ_cd == $0.lag_capt_typ_cd
                            && uhdRentItem.rsluTypCd != $0.rsluTypCd})
                    .sorted(by: {$0.prdPrcFrDt > $1.prdPrcFrDt}).first {
                    tempDic[$0] = [item]
                }
            } else {
                //시리즈면 현재시놉의 에피소드 아이디만 사용.(시리즈면서 더빙/자막 있는게 있나..)
                var minItem: PurchasModel?
                //구매했으면 노출순위 제일 낮은거.(최우선, 소장) 미구매면 제일 높은거.(최하위, 대여)
                if let temp = $1.min(by: {
                    var result = false
                    //pps ppm은 대여 노출해야됨.
                    if isDirectview && !isSeasonWatchAll && !isPurchasedPPM {
                        result = $0.purchaseProductRank < $1.purchaseProductRank
                    } else {
                        result = $0.purchaseProductRank > $1.purchaseProductRank
                    }
                    return result
                }) {
                    minItem = temp
                }
                if let minItem = minItem,
                    let item = $1.filter({ $0.purchaseProductRank == minItem.purchaseProductRank })
                        .sorted(by: {$0.prdPrcFrDt > $1.prdPrcFrDt}).first {
                    tempDic[$0] = [item]
                }
            }
        }
        
        var watchOptions = tempDic.flatMap({ $1 })
        if watchOptions.count == 0 {
            //아무것도 없으면 예외처리로 무조건 하나 추가.
            if let temp = self.getDefaultItem() { watchOptions = [temp] }
        }
        //"본편/자막/더빙 필터링 끝"
        watchOptions = watchOptions.sorted(by: { $0.index < $1.index })
        
        if purchasedPid != nil || purchasedPid != "none" {
            curSynopsisItem =  watchOptions.first(where: { $0.prd_prc_id == purchasedPid })
        }
        //구매한게 ppv 아닐 경우, 시놉시스 와 매핑되는 아이템 사용.
        if curSynopsisItem == nil {
            if let temp =  watchOptions.first(where: {self.epsdId == $0.epsd_id }) {
                curSynopsisItem = temp
            } else {
                curSynopsisItem =  watchOptions.first
            }
        }
        self.watchOptionItems = watchOptions
        //현재아이템 권한x 무료x 맛보기x면 구매가능으로 추가.
        if let curSynopsisItem = curSynopsisItem, !curSynopsisItem.isDirectview && !curSynopsisItem.isFree && !isGstn {
            purchasableItems.append(curSynopsisItem)
        }
        
        
        if self.distStsCd == .expired { self.isDistProgram = curSynopsisItem?.isDirectview ?? false }
       
        //아이템 nscreen 말고 시놉시스 nscreen 참조해야함.(덤앤더머2 다름.)
        let tempNextPurchaseItems = usableItems.filter({!$0.isDirectview && $0.isUse && $0.isSalesPeriod && !$0.isFree && isNScreen})
        tempNextPurchaseItems.forEach {
            guard let curSynopsisItem = curSynopsisItem else { return }
            if isPurchasedPPM {
                isPurchasableNextStep = false
                return
            }
            if !$0.isDirectview && $0.isUse && $0.isSalesPeriod {
                //단편 등급이 같으면(자막|소장 구매, 우리말|소장 미구매 상태 등) 다른 에피소드(언어타입 다름)
                if curSynopsisItem.purchaseProductRank == $0.purchaseProductRank {
                    if self.srisTypCd == .title && curSynopsisItem.epsd_id != $0.epsd_id {
                        purchasableItems.append($0)
                        isPurchasableNextStep = true
                    }
                //등급이 다르면 기본 체크 사용.
                } else if curSynopsisItem.purchaseProductRank > $0.purchaseProductRank {
                    purchasableItems.append($0)
                    isPurchasableNextStep = true
                }
            }
        }
        #if DEBUG
        //log
        watchOptions.forEach({
            DataLog.d("watchOption : " + $0.debugString, tag: self.tag)
        })
        purchasableItems.forEach({
            DataLog.d("purchasable : " + $0.debugString, tag: self.tag)
        })
    
        DataLog.d("isNScreen : " + self.isNScreen.description , tag: self.tag)
        DataLog.d("isPurchasedPPM : " + self.isPurchasedPPM.description  , tag: self.tag)
        DataLog.d("isContainPPM : " + self.isContainPPM.description , tag: self.tag)
        DataLog.d("isContainPPS : " + self.isContainPPS.description , tag: self.tag)
        DataLog.d("isPurchased : " + self.isPurchased.description , tag: self.tag)
        DataLog.d("holdbackType : " + self.holdbackType.name , tag: self.tag)
        DataLog.d("purchasedPPMItem : " + (self.purchasedPPMItem?.ppm_prd_nm ?? "nil") , tag: self.tag)
        
        
        DataLog.d("curSynopsisItem : " + (curSynopsisItem?.debugString ?? "nil") , tag: self.tag)
        
        #endif
    }
    
    var isOnlyPurchasedBtv: Bool {
        !isSingleTrstrs && isOnlyCommerce && !isSeasonWatchAll
    }
    
    // 현재 시놉시스 판매 상품 월정액 가입 여부. (filterSynopsisItem 에서 purchasedPPMItems yn_direct ppm 추가함.)
    // 시리즈 월정액일 경우 회차 변경시 사용.
    var isPurchasedPPM: Bool {
        purchasModels.filter({PrdTypCd.isPPM(typCd: $0.prdTypCd, all: true)})
        .contains(where: { curPpm in
            purchasedPPMItems.contains(where: {
                curPpm.prd_prc_id == $0.prd_prc_id
            })
        })
    }
    var purchasedPPMItem: PurchasModel? {
        purchasModels.filter({PrdTypCd.isPPM(typCd: $0.prdTypCd, all: true)})
       .first(where: { curPpm in
           purchasedPPMItems.contains(where: {
               curPpm.prd_prc_id == $0.prd_prc_id
           })
       })
    }
    //월정액 상품 포함 여부
    var isContainPPM: Bool {
        purchasModels.contains(where: { PrdTypCd.isPPM(typCd: $0.prdTypCd, all: true) })
    }
    var isContainPPS: Bool {
        purchasModels.contains(where: { $0.prdTypCd == .pps })
    }
    
    //1사 지상파일때만 유효.
    var holdbackType: HoldbackType {
        if !isSingleTrstrs { return .none }
        //product / purchase 합친 목록에서 proudct만 찾음.
        let productList = purchasModels.filter({ $0.originType == .product && $0.isUse && $0.isSalesPeriod })
            .sorted(by: { $0.prdPrcFrDt > $1.prdPrcFrDt })
        if productList.count > 0,
            let synopEpsdId = self.epsdId,
            let target = productList.first(where: { $0.epsd_id ==  synopEpsdId }),
            target.sale_prc_vat != 0 {
            //시리즈경우 필터링시 ppv 면서 시놉시스의 에피소드인 아이템만 찾아서 동일하곘지만
            //예외상황 발생체크를 위해 현재 아이템과 다를 경우 로그 출력 추가.
            if let cur = curSynopsisItem, target.prd_prc_id != cur.prd_prc_id {
                DataLog.d("cur : " + cur.debugString, tag: self.tag)
            }
            return .holdIn
        }
        return .holdOut
    }
    
    private var isSingleTrstrs: Bool {
        srisTypCd == .season && purchasModels.contains(where: {
            SynopsisModel.singleTrstrsPidList.contains($0.prd_prc_id)
        })
    }
    private var isTrstrs: Bool {
        srisTypCd == .season && purchasModels.contains(where: {
            SynopsisModel.trstrsPidList.contains($0.prd_prc_id)
        })
    }
    private var isOnlyCommerce: Bool {
        srisTypCd == .season
            && purchasModels.filter({ $0.sale_tgt_fg_yn == "Y" })
            .contains(where: { !($0.poc_det_typ_cd_list?.contains("102") ?? false) })
    }
    
    
    
    private var isPurchased: Bool {
        purchasModels.contains(where: {$0.isDirectview})
    }
    
    
   

    // 현재 시놉의 시즌 전체 시청 가능 여부( 시리즈 아이디로 pps 캐싱된거있나 찾음)
    private var isSeasonWatchAll: Bool {
        purchasModels.filter({$0.prdTypCd == .pps})
        .contains(where: { curPps in
            purchasedPPSItems.contains(where: {
                curPps.prd_prc_id == $0.prd_prc_id
            })
        })
    }
    
    private func getDefaultItem() -> PurchasModel? {
        if self.purchasModels.isEmpty { return nil }
        let tempUsableItems = self.purchasModels.filter({ $0.isUse && $0.isSalesPeriod })
        let tempFilteredItems = tempUsableItems.filter({ $0.rsluTypCd <= .fhd })
        //uhd 이상 필터링, 필터링 목록 0개면 포함된 목록 사용.
        let defItems = tempFilteredItems.count > 0 ? tempFilteredItems : tempUsableItems
        let temp = defItems.contains(where: {$0.isFree }) ? defItems.filter({ $0.isFree }) : defItems.filter({ $0.epsd_id == epsdId })
        if !temp.isEmpty {
            if let ppvItem = temp.sorted(by: { $0.prdPrcFrDt > $1.prdPrcFrDt }).first(where: {$0.prdTypCd == .ppv}) {
                return ppvItem
            }
            return temp.sorted(by: { $0.prdPrcFrDt > $1.prdPrcFrDt }).first
        }
        let filtered = defItems.sorted(by: { $0.prdPrcFrDt > $1.prdPrcFrDt })
        return filtered.first
    }
}
