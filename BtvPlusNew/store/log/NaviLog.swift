//
//  NaviLog.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/08/10.
//

import Foundation
import Foundation
struct NaviLog {
    enum PageId: String {
        case play = "/play"                                 // 09. 재생
        case kidsPlay = "/category/zemkids/play" // ZEM 키즈 재생
        case playTouchGuide = "/play/touch_guide"
        case playInside = "/play/inside"                    // 재생 | 인사이드
        case popup = "/popup"                               // GNB팝업
        case prohibitionSimultaneous = "/limit_multiple_screen"
        
        case pairingLimited = "/my/connect_stb/detail/subscriber_auth/stb_selection" // 세탑 여러개
        case pairingCompleted = "/my/connect_stb/btv_auth_number/completed"
        case pairingDeviceNotfound = "/my/connect_stb/detail/subscriber_auth/there_is_no_stb"
        case autoPairing = "/autopairing" // 자동연결페어링
        case searchResult = "/search/result"                      // 검색결과
        case zemSearchResult = "/category/zemkids/search" // ZEM 키즈|검색결과
        case remoteconStatus = "/remotecon/status"          // 리모컨 세부상태
        
        case purchaseOrderCompleted = "/purchase/order_completed"   // 상품구매완료
        case event = "/event"
        
        case networkError = "/network_error"
        case appPush = "/app_push"
        
        case clipViewAll = "/category/clip_view_all"
        case scheduled = "/scheduled"
        case recentContents = "/my/recent_contents"
        case synopsis = "/synopsis"
        case kidsSynopsis = "/category/zemkids/synopsis"
        
    }
    static func getPageID(pageID:PageID? = nil, repository:Repository?)-> String?{
        guard let pageID = pageID else {return nil}
        return Self.getPageID(page: nil, pageID: pageID, repository: repository)
    }
    static func getPageID(page:PageObject? = nil, repository:Repository?)-> String?{
        guard let page = page else {return nil}
        return Self.getPageID(page: page, pageID: page.pageID, repository: repository)
    }
    static func getPageID(page:PageObject?, pageID:PageID, repository:Repository?)-> String?{
        switch pageID {
        case .intro : return "/guide"
        case .auth: return nil
        case .serviceError: return nil
        case .home:
            if let menuId = page?.getParamValue(key: .id) as? String,
               let band = repository?.dataProvider.bands.getData(menuId: menuId) {
                switch  band.gnbTypCd{
                case EuxpNetwork.GnbTypeCode.GNB_OCEAN.rawValue: return "/ocean"
                case EuxpNetwork.GnbTypeCode.GNB_MONTHLY.rawValue : return "/monthly_payment"
                case EuxpNetwork.GnbTypeCode.GNB_FREE.rawValue : return "/free"
                default: return "/home"
                }
            }
            return nil
        case .category: return "/category"
        case .synopsis: return nil
        case .synopsisPackage: return nil
        case .synopsisPlayer: return nil
        
        case .my:
            if repository?.pairing.status == .pairing {
                return "/my/profile"
            } else {
                return "/my/connect_stb"
            }
        case .myPurchase: return "/my/purchase_list"
        case .myBookMark: return "/my/pick_contents"
        case .myBenefits: return "/my/coupon_point"
        case .myAlram: return "/my/notifications"
        case .myPurchaseTicketList: return nil
        case .myRecommand: return nil
        case .myPossessionPurchase: return "/my/connect_stb/vod_basket_contents"
        case .myRegistCard: return nil
        case .modifyProile: return "/my/profile/edit"
        case .setup: return "/setup"
        case .terminateStb: return nil
        case .myOksusuPurchase : return "/my/oksusu_contents"
            
        case .pairing: return "/my/connect_stb/detail"
        case .pairingSetupUser: return "/my/profile/registration"
        case .pairingDevice: return "/my/connect_stb/detail/wifi"
        case .pairingBtv: return "/my/connect_stb/btv_auth_number"
        case .pairingUser: return "/my/connect_stb/detail/subscriber_auth"
        case .pairingManagement: return "/my/connect_stb/mgmt"
        case .pairingEmptyDevice: return nil
        case .pairingGuide: return nil
        case .pairingAppleTv: return "/connect_atlanta"
        case .pairingFamilyInvite: return nil
      
        case .purchase: return nil
        case .multiBlock: return "/category"
        case .categoryList: return nil
        case .previewList: return nil //페이지에서 직접처리
        case .watchedList: return nil //페이지에서 직접처리
        case .fullPlayer: return nil
        
        case .webview: return nil
        case .person: return nil
        case .search: return "/search"
        case .schedule: return "/epg"
        case .adultCertification: return "/adult_certification"
        case .userCertification: return nil
        case .confirmNumber: return nil
        case .watchHabit: return nil
        case .purchaseList: return nil
        
        case .couponList: return nil
        case .privacyAndAgree: return nil
        case .remotecon: return "/remotecon"
        case .playerTest: return nil
        case .playerTestList: return nil
        case .cashCharge: return nil
        case .cashChargeGuide: return nil
        case .cashChargePrivacyAndAgree: return nil
        case .recommand: return nil
        case .recommandReceive: return nil
        case .snsShare: return nil
            
        case .kidsIntro: return nil
        case .kidsHome: return "/category/zemkids"
        case .registKid: return "/zemkids_certification_popup"
        case .editKid: return "/category/zemkids/mypage/profile"
        case .kidsMy: return "/category/zemkids/mypage"
        case .kidsMyDiagnostic: return "/category/zemkids/mypage/level_test_report"
        case .kidsProfileManagement: return "/category/zemkids/mypage/profile"
        case .kidsEnglishLvTestSelect: return "/category/zemkids/mypage/level_test"
        case .kidsExam:
            /*
            if let type = page.getParamValue(key: .type) as? DiagnosticReportType {
                switch  type {
                case .english, .creativeObservation, .infantDevelopment : return "/category/zemkids/mypage/level_test"
                default: return nil
                }
            }*/
            return nil
        case .kidsExamViewer: return nil
        case .kidsMyMonthly: return "/category/zemkids/mypage/monthly_report"
        case .selectKidCharacter: return nil
        case .kidsConfirmNumber: return "/zemkids_certification_popup"
        case .kidsMultiBlock:
            if let pageType = page?.getParamValue(key: .type) as? BlockData.UiType{
                switch  pageType{
                case .kidsTicket: return "/category/zemkids/monthly_payment/tab_menu"
                default: return "/category/zemkids/tabmenu"
                }
            } else {
                return "/category/zemkids/tabmenu"
            }
           
        case .kidsCategoryList: return nil
        case .kidsMonthly: return "/category/zemkids/monthly_payment"
        case .kidsSynopsis: return nil
        case .kidsSynopsisPackage: return nil
        case .kidsSearch: return nil
        case .tabInfo: return nil
        case .detailInfo: return nil
        default : return nil
        }
    }
    
    static func getPageAction(page:PageObject, repository:Repository)-> MenuNaviActionBodyItem?{
        switch page.pageID {
        case .kidsHome:
            var actionBody = MenuNaviActionBodyItem()
            let dataProvider = repository.dataProvider
            let menuId = page.getParamValue(key: .id) as? String ?? dataProvider.bands.kidsGnbModel.home?.menuId ?? ""
            let blockData = dataProvider.bands.kidsGnbModel.getGnbData(menuId: menuId)
            //actionBody.menu_id = blockData?.menuId
            actionBody.result = blockData?.title
            return actionBody
        case .kidsMultiBlock:
            if let pageType = page.getParamValue(key: .type) as? BlockData.UiType{
                switch  pageType{
                case .kidsTicket:
                   // let title = page.getParamValue(key: .title) as? String
                    let monthly =  page.getParamValue(key: .data) as? MonthlyData
                    var actionBody = MenuNaviActionBodyItem()
                    actionBody.config = monthly?.title
                    return actionBody
                default: return nil
                }
            } else {
                return nil
            }
        case .category:
            let pushId = page.getParamValue(key: .pushId) as? String ?? ""
            let actionBody = MenuNaviActionBodyItem(category:pushId )
            return actionBody
        case .myAlram:
            let actionBody = MenuNaviActionBodyItem(config:repository.pairing.user?.isAgree3 == true ? "ON" : "OFF")
            return actionBody
        case .registKid:
            let actionBody = MenuNaviActionBodyItem(menu_name:"자녀프로필등록")
            return actionBody
        case .kidsConfirmNumber:
            let type = page.getParamValue(key: .type) as? PageKidsConfirmType
            let actionBody = MenuNaviActionBodyItem(menu_name:type?.logMenuName)
            return actionBody
        case .kidsProfileManagement:
            let actionBody = MenuNaviActionBodyItem(menu_name:String.kidsTitle.registKidManagement)
            return actionBody
        case .editKid:
            var actionBody = MenuNaviActionBodyItem()
            if let _ = page.getParamValue(key: .data) as? Kid {
                actionBody.menu_name = String.kidsTitle.editKid
            } else {
                actionBody.menu_name = String.kidsTitle.registKid
            }
            return actionBody
       
        default : return nil
        }
    }
    
    enum Action: String {
        case none
        case pageShow = "page_show" // 페이지 진입
        //비기너스 가이드
        case clickGuideSkip = "click.guide.skip"
        case clickGuideButton = "click.guide.button"
        // 01 홈
        case clickTopGnbRemotecon = "click.top_gnb.remotecon"   // 1. 상단 리모컨 선택
        case clickTopGnbSearch = "click.top_gnb.search"         // 2. 상단 검색 선택
        case clickTopGnbMy = "click.top_gnb.my"                 // 3. 상단 my 선택
        case clickTopGnbNotice = "click.top_gnb.notice"         // 탑메뉴 > Alert 말풍선
        case clickBottomGnbMenu = "click.bottom_gnb.menu"       // 7. 배너
        case clickBannerBanner = "click.banner.banner"          // 5. 빅배너 선택
        case clickBannerLineBanner = "click.banner.line_banner"          // 띠배너 선택
        // 02 월정액
        case clickTopGuide = "click.top.guide"                        // 1. 상단 가이드 선택 시
        // 04 카테고리
        case clickCategoryMenu = "click.category.menu"                // 카테고리 메뉴 선택
        case clickBottomMenu = "click.bottom.menu"                    // 카테고리 하단 메뉴
        case clickGnbMenu = "click.gnb.menu"                          // 카테고리 하위 페이지 서브 메뉴 선택
        case clickButtonMenu = "click.button.menu"                    // 하단 버튼 선택
        // 카드 선택
        case clickContentsView = "click.contents.view"                //모든 카드 선택시 호출
        // 05 공개예정
        case clickMovieOption = "click.movie.option"                  // 1. 좋아요/알림 선택
        case clickScheduledMoviePlay = "click.scheduled_movie.play"   // 2. 예정영화 홍보영상 재생 선택
        case clickLikeSelection = "click.like.selection"              // 3. 좋아요/그렇지 않아요 선택
        case clickLikeSelectionCancel = "click.like.selection_cancel" // 4. 취소
        // 06 리모컨
        case clickRemoteconExit = "click.remotecon.exit"             // 3-2. 리모컨 종료 선택
        case clickRemoteconPower = "click.remotecon.power"           // 4. 리모컨 전원
        case clickRemoteconColor = "click.remotecon.color"           // 5. 리모컨 컬러 키
        case clickRemoteconHomeMove = "click.remotecon.home_move"    // 6. 리모컨 홈/이동 키
        case clickRemoteconFunction = "click.remotecon.function"     // 7. 리모컨 펑션 키
        // 07 성인인증
        case clickCertificationExit = "click.certification.exit"    // 1. 나가기 선택
        // 08 시놉
        case clickContentsPlay = "click.contents.play"
        case clickContentsPause = "click.contents.pause"   // 1. 미리보기/바로시청 선택
        case clickContentsPick = "click.contents.pick"              // 2-1. 찜하기 선택
        case clickContentsLike = "click.contents.like"              // 2-2. 평가하기 선택
        case clickContentsWatchBtv = "click.contents.watch_btv"     // 2-3. Btv로보기 선택
        case clickContentsOrder = "click.contents.order"            // 3. 구매하기 선택
        case clickViewMore = "click.view.more"                      // 4. 더보기
        case clickTabSeries = "click.tab.series"                    // 5-2. 시리즈 탭메뉴 선택
        case clickContentsList = "click.contents.list"              // 6. 시리즈 탭메뉴 선택
        // 09 재생
        case clickVodPlay = "click.vod.play"                        // 0. 재생(/play) 페이지 진입(방문) 시
        case clickVodPause = "click.vod.pause"
        case clickVodStop = "click.vod.stop"
        case clickPlayBackList = "click.play.back_list"             // 1. 재생 중 시리즈 목록으로 가기 선택
        case clickVodConfig = "click.vod.config"                    // 3. 재생 컨텐츠의 설정 선택
        case clickVodConfigEtc = "click.vod.config_etc"             // 4. 재생 컨텐츠의 기타설정 선택
        case clickVodScreenOption = "click.vod.screen_option"       // 5. 재생 컨텐츠의 화면 설정 변경 선택
        case clickVodConfigExit = "click.vod.config_exit"           // 6. 재생 컨텐츠의 옵션 팝업 종료 선택
        case clickVodConfigDetail = "click.vod.config_detail"       // 7. 재생 컨텐츠의 세부설정
        // 10 편성표
        case clickGnbExit = "click.gnb.exit"                        // 2. 편성표(/epg) 나가기
        // 11 스마트 검색
        case clickContentsVoice = "click.contents.voice"            // 2. 음성검색 선택
        case clickSearchBack = "click.search.back"                  // 4. 검색입력 페이지 뒤로가기 선택
        // 15 MY_연결
        case clickConnectionButton = "click.connection.button"      // 1. B tv 연결하기 선택
        case clickReleaseButton = "click.release.button"            // 2-2. B tv 연결 해제하기 선택
        case clickConnectSelection = "click.connect.selection"      // 1. B tv 연결하기 선택
        case clickReleasePopupButton = "click.release.popup_button" // 3. B tv 연결 해제 취소/해제 버튼 선택
        case clickConnectStbConfirm = "click.connect_stb.confirm"   // 4. B tv 인증번호로 연결하기 버튼 선택
        // 16. MY_프로필
        case clickProfileEdit = "click.profile.edit"                // 1. 프로필 수정하기 선택
        case clickConnectTvSetup = "click.connect_tv.setup"         // 2. TV 연결설정 선택
        case clickMyBenefitInfo = "click.my_benefit.info"           // 3. 이용권/쿠폰/포인트 선택
        case clickMyPaymentsInfo  = "click.my_payments.info"        // 4. 결제정보 선택
        case clickMyRecentsContents = "click.my_recents.contents"   // 5. 최근시청목록 선택
        case clickMyPickList = "click.my_pick.list"                 // 6-1. 찜 목록 선택
        case clickMyPurchaseList = "click.my_purchase.list"         // 6-2. 구매 목록 선택
        case clickMyOptionInfo = "click.my_option.info"             // 7. 공지사항/도움말FAQ/B World 선택
        case clickProfileConfirm = "click.profile.confirm"          // 8. 프로필 변경의 확인선택
        case clickRecentKidsContentsList = "click.recent_kids_contents.list" //마이 > 최근 시청 목록 > 잔체보기 > 잼키즈 시청목록
        // 17 결제정보
        case clickPaymentTabMenu = "click.payment.tab_menu"         // 1. 탭 메뉴 선택
        case clickPaymentAdd = "click.payment.add"                  // 2. 카드등록 선택
        // 18 쿠폰/포인트
        case clickCouponPointTabMenu = "click.coupon_point.tab_menu"
        case clickCouponPointAdd = "click.coupon_point.add"
        case clickCouponPointOption = "click.coupon_point.option"
        case clickOkPointCheck = "click.ok_point.check"
        case clickCardRegister = "click.card.register"
       
        // 19.최근시청_찜_구매목록
        case clickRecentContentsList = "click.recent_contents.list"     // 1. 최근시청 목록 내 컨텐츠 선택
        case clickPickContentsList = "click.pick_contents.list"         // 2. 찜 목록 내 컨텐츠 선택
        case clickPurchaseListTabMenu = "click.purchase_list.tab_menu"  // 1. 탭 메뉴 선택
        case clickPurchaseListList = "click.purchase_list.list"         // 2. 탭 메뉴 선택
        // 21 상품구매
        case clilckOrderExit = "clilck.order.exit"                      // 1. 상품구매 페이지 나가기 선택
        //////////////////////////////////////////////////////////////////////////////
        // v4.1.0
        //////////////////////////////////////////////////////////////////////////////
        // /synopsis
        case clickContentsShare = "click.contents.share"            // 10. 콘텐츠 공유
        case clickContentsPreviewWatching = "click.contents.preview_watching" // 11. 구매전 컨텐츠 미리보기, 구매 후 시청하기 선택
        // /play/insdie
        case clickInsideSkipIntro = "click.inside.skip_intro"       // 2. 도입부 건너뛰기
        // /scheduled
        case clickMovieStory = "click.movie.story"                  // 6.
        // /home
        case clickTopGnbZemkids = "click.top_gnb.zemkids"           // 10. 상단 젬키즈 선택
        case clickTopGnbEpg = "click.top_gnb.epg"                   // 11. 상단 편성표 선택
        //////////////////////////////////////////////////////////////////////////////
        // v4.2.0
        //////////////////////////////////////////////////////////////////////////////
        // /setup
        case clickConfigSelection = "click.config.selection"                         // 3. 설정 내 선택한 모든 설정의 텍스트
        // /synopsis, /play
        case clickContentsProductionActor = "click.contents.production_actor"        // 12. 제작/출연진 및 줄거리의 배우선택
        case clickAdButton = "click.ad.button"                                       // 13. 프리롤 광고 버튼 선택
        // /popup
        case clickPopupContents = "click.popup.contents"                             // 2. 팝업 내 배너 선택
        case clickPopupButton = "click.popup.button"                                 // 3. 팝업 하단의 버튼 선택
        // /my/profile
        case clickInfoButton = "click.info.button"                                   // 10. 알림, 모비소식 선택
        // /my/payment
        case clickPaymentSubMenu = "click.payment.sub_menu"                          // 3. 탭내 하위메뉴 선택
        // /my/notifications
        case clickNotificationList = "click.notification.list"                      // 2. 알림 목록 선택
        case clickNotificationBack = "click.notification.back"                      // 3. 뒤로 가기
        case clickNotificationButton = "click.notification.button"                  // 4. 알림 설정 ON 선택
        
        // /my/connect_stb/mgmt
        case clickInviteButton = "click.invite.button"                              // 4. MY 연결해제/관리
        // /remotecon
        case clickWatchingInfoRefresh = "click.watching_info.refresh"               // 7. 시청 중인 정보 영역의 새로고침 버튼 선택
        // /search/result
        case clickContentsSeriesBack = "click.contents.series_back"                 // 6. 블럭 영역 별 전체보기
        //////////////////////////////////////////////////////////////////////////////
        // v4.2.2
        //////////////////////////////////////////////////////////////////////////////
        // /remotecon/status
        case clickStatusButton = "click.status.button"                      // 2. 시청 중인 정보 영역의 새로고침 버튼 선택
        // /remotecon
        case clickFamilyEarphone = "click.family.earphone"                  // 8.
        // /app_push
        case clickAppPushMessage = "click.app_push.message"                 // 2. 앱푸쉬 선택
        // //my/connect_stb/vod_basket_contents
        case clickContentsListView = "click.contents_list.view"             // 2. 구매소장목록VOD 목록 중 컨텐츠 선택
        case clickContentsListBack = "click.contents_list.back"             // 3. 뒤로가기 선택
        // /my/connect_stb
        case clickBasketContentsButton = "click.basket_contents.button"     // 4. 미페어링사용자의 소장VOD가져오기
        //////////////////////////////////////////////////////////////////////////////
        // v4.3.0
        //////////////////////////////////////////////////////////////////////////////
        // /my/purchase_list
        case clickPurchaseListEdit = "click.purchase_list.edit"     // 4.
        case clickPurchaseListDelete = "click.purchase_list.delete"     // 5.
        // /my/notifications
        case clickNotificationAllasread = "click.notification.allasread"     // 5.
        case clickNotificationPopUp = "click.notification.pop_up"     // 6.
        // /purchase/order_completed
        case clickOrderCompletedConfirm = "click.order_completed.confirm"    // 2.
        //////////////////////////////////////////////////////////////////////////////
        // v4.3.5
        //////////////////////////////////////////////////////////////////////////////
        // /my/profile
        case clickSimpleSetup = "click.simple.setup"  // 11.
        // /play
        case clickWatchOriginalButton = "click.watch_original.button"   // 11.
        //////////////////////////////////////////////////////////////////////////////
        // v4.4.0
        //////////////////////////////////////////////////////////////////////////////
        // /category/zemkids
        case clickSaldongTabMenu = "click.saldong.tab_menu"    // 6.
        case clickTopGnbMenu = "click.top_gnb.menu"    // 7.
        case clickSecondsDepthMenu = "click.seconds_depth.menu"    // 8.
        case clickProfileRegisterButton = "click.profile_register.button"    // 9.
        case clickPromotionBanner = "click.promotion.banner"    // 10.
        
        // /category/zemkids/tabmenu
        case clickContentsButton = "click.contents.button"    // 3.
        
        // /category/zemkids/synopsis
        case clickPurchaseButton = "click.purchase.button"   // 3.
        case clickCaptionOption = "click.caption.option"   // 4.
        case clickContentsOrderOption = "click.contents_order.option"   // 5.
        case clickRelatedContentsOption = "click.related_contents.option"   // 6.
        case clickContentsOption = "click.contents.option"   // 7.
        
        // /play
        case clickVodReplay = "click.vod.replay"   // 12. 재생버튼 선택
        case clickVodNextEpisode = "click.vod.next_episode"   // 13. 재생버튼 선택
        
        // /category/zemkids/mypage
        case clickSettingButton = "click.setting.button"   // 2. 설정버튼
        case clickConnectStbButton = "click.connect_stb.button"   // 3. btv연결버튼
        case clickTabMenu = "click.tab.menu"   // 4. 탭메뉴버튼
        case clickProfileSetting = "click.profile.setting"   // 5.
        case clickSecondDepthMenu = "click.second_depth.menu"   // 6.
        case clickThirdDepthMenu = "click.third_depth.menu"   // 7.
        case clickContentsMore = "click.contents.more"   // 10.
        
        // /category/zemkids/mypage/monthly_report
        case clickTabMenuButton = "click.tab_menu.button"   // 2. 상단탭선택
        case clickAnotherMonthButton = "click.another_month.button"   // 3. 년/월설정
        
        // /category/zemkids/mypage/level_test
        case clickTestLevelOption = "click.test_level.option"   // 2.
        case clickNextButton = "click.next.button"   // 3.
        case clickExitButton = "click.exit.button"   // 4.
        
        // /category/zemkids/search_input
        case clickSearchTextInput = "click.search.text_input"   // 2. 텍스트 검색
        case clickSearchVoiceInput = "click.search.voice_input"   // 3. 음성 검색
        // /category/zemkids/search_result
        case clickContentsViewAll = "click.contents.view_all"   // 3. 전체보기
        case clickVoiceTextButton = "click.voice_text.button"   // 4. 검색결과창에서 텍스트로 검색
        case clickTextSearchButton = "click.text_search.button"   // 5. 검색결과창에서 음성으로 검색
        // /category/zemkids/mypage/level_test_report
        case clickOptionMenu = "click.option.menu"   // 3.
        // /zemkids_certification_popup
        case clickConfirmButton = "click.confirm.button"   // 2.
        // /category/zemkids/monthly_payment
        case clickPaymentMenu = "click.payment.menu" // 2.
        // /category/zemkids/monthly_payment/tab_menu
        case clickSubscriptionButton = "click.subscription.button" // 5.
        case clickCloseButton = "click.close.button"
        
        case clickClipStoryButton = "click.clip_story.button"
        case clickContentsRetrievePopup = "click.contents_retrieve.popup"
        case clickContinuousPlayButton = "click.continuous_play.button"
        case clickInsidePlayButton = "click.inside_play.button"
        case deleteRecentContentsList = "delete.recent_contents.list"
        
        case clickMyOksusuPurchaseList = "click.my_oksusu_purchase.list"
       
    }
    
    enum watchType: String {
        case none
        case watchStart = "start"       // click.vod.play  (play 버튼 선택 시)→ "vod_watch_type" : "start"
        case watchStop = "stop"         // click.vod.pause  (잠시 중단 버튼 선택 시) → "vod_watch_type" : "pause"
        case watchPause = "pause"       // click.vod.stop  (정지 버튼 선택 시) → "vod_watch_type" : "stop"
    }
}



struct MenuNaviItem : Encodable {
    var service_name:String? = nil               // 서비스 구분 이름
    var device_base_time:String? = nil            // 단말의 로그 발생 시간
    var server_received_time:String? = nil        // 로그서버가 로그를 수신받은 시간
    var log_type:String? = nil                   // 로그개발/상용 구분을 단말에서 설정
    var poc_type:String? = nil                   // 단말의 point of contact 구분
    var page_id:String? = nil                    // 서비스의 논리적 위치 정보
    var menu_id:String? = nil                    // 서비스의 메뉴 ID 정보
    var page_path:String? = nil                  // 서비스의 전체 메뉴 경로
    var action_id:String? = nil                  // 페이지에서 발생한 액션 정보
    var vod_watch_type:String? = nil              // vod의 시청 유형
    var stb_onead_id:String? = nil                // 연결된 STB ONEAD ID,
    var pcid:String? = nil                      // 사용자 구분을 위한 cookie ID
    var stb_id:String? = nil                     // STB의 고유 구분 ID
    var stb_mac:String? = nil                    // STB의 유선 MAC address
    var session_id:String? = nil                 // PCID+랜덤번호 5자리
    var page_type:String? = nil                  // 페이지 구분유형
    var app_release_version:String? = nil         // Navite 상용 출시 버전
    var web_page_version:String? = nil            // Web 상용 출시 버전
    var stb_fw_version:String? = nil              // STB firmware 버전, Btvplus는 미전송
    var os_name:String? = nil                    // OS 이름
    var os_version:String? = nil                 // OS 버전
    var browser_name:String? = nil               // 브라우저 이름
    var browser_version:String? = nil            // 브라우저 버전
    var device_model:String? = nil               // STB 모델명 (필요 시 smartphone추가)
    var manufacturer:String? = nil              // STB 제조사 (필요 시 smartphone추가)
    var edid:String? = nil                      // edid 추출정보
    var deeplink:String? = nil                  // 외부유입정보
    var thirdparty_app:String? = nil             // 3rd party app 구분
    var nugu_voice_text:String? = nil             // 발화 텍스트
    var gaid:String? = nil                      // Android Advertising ID
    var idfa:String? = nil                      // iOS Advertising ID
    var url:String? = nil                       // URL정보-web만 해당
    var client_ip:String? = nil                  // client device의 IP주소
    var app_build_version:String? = nil           // App의 세부 버전 구분정보
    
    var member:MenuNaviMemberItem? = nil                // 사용자 정보
    var action_body:MenuNaviActionBodyItem? = nil            // 액션ID로부터 추가로 분석할 정보
    var contents_body:MenuNaviContentsBodyItem? = nil              // 선택한 컨텐츠의 관련 정보
    var rcu_key:String? = nil                // STB remocon 주요 key 정보 (방향, 볼륨, 채널 제외)
    var ab_test:String? = nil                    // AB test 시 사용할 컬럼
    var remote_control:String? = nil        // 리모컨 관련 정보
}

struct MenuNaviContentsBodyItem : Encodable {
    var type:String? = nil          // VOD/실시간 구분 ex)vod | live
    var title:String? = nil         // 제목, ex)1박2일, 9시 뉴스
    var channel:String? = nil     // live방송의 채널번호
    var channel_name:String? = nil     // channel 명
    var genre_text:String? = nil     // 장르, ex)영화
    var genre_code:String? = nil     // 장르, ex)MG0000000001 --> 드라마
    var paid:Bool? = nil                // 유료 여부 ex)true (유료인 경우)
    var purchase:Bool? = nil           // 구매 여부 ex)true (구매한 경우)
    var episode_id:String? = nil     // episode_id, btv plus 는 episode_id 없음, 5.0
    var episode_resolution_id:String? = nil     // episode_id, btv plus 는 episode_id 없음, 5.0
    var cid:String? = nil           // 4.0
    var product_id:String? = nil           // 패키지상품 ID(Btv plus) or 시리즈상품 ID(Btv)
    var purchase_type:String? = nil  // 구매유형, ex) ppv(단품)/pps(시리즈)/ppp(패키지)/ppm(월정액) --> 재생 버튼 선택 후 확인 가능
    var monthly_pay:String? = nil    // 월정액유형, ex)프리미어, 프리미어 라이트, 지상파월정액, JTBC월정액
    var running_time:String? = nil   // 초단위
    var list_price:String? = nil     // 할인 전 가격
    var payment_price:String? = nil  // 할인 후 최종 결제 시 지불한 가격
    var actor_id:String? = nil  // 배우ID
    var series_id:String? = nil  // 시리즈ID
}


struct MenuNaviActionBodyItem : Encodable {
    var menu_id:String? = nil          // 구분가능한ID
    var menu_name:String? = nil        // 한글메뉴이름
    var config:String? = nil          // config
    var position:String? = nil        // 위치 또는 순서
    var search_keyword:String? = nil   // searchKeyword
    var category:String? = nil        // category
    var target:String? = nil          // target
    var result:String? = nil          // 결과 텍스트
}

struct MenuNaviMemberItem : Encodable {
    var gender:String? = nil      // male | female
    var birthyear:String? = nil      // 2018
    var nickname:String? = nil     // 뽀로로
}
