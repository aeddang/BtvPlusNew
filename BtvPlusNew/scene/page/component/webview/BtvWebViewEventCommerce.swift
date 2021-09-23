//
//  BtvWebViewEventAtt.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/08/29.
//

import Foundation


extension BtvWebView{
    
    struct EventCommerceData {
        var callback:String? = nil
        var goodsid :String
        var pid :String
        var epsd_id :String
        var sris_id :String
        var synopsis_type :String
        var ptype :String
        var conTitle :String
        var pidOnly :String
        var monthlyTitle :String? = nil
    }

    func callFuncionEventCommerce(fn:String, jsonParams:String?, callback:String? ){
        switch fn {
        case WebviewMethod.bpn_eventCommerce.rawValue :
            if self.pairing.status != .pairing {
                self.appSceneObserver.alert = .needPairing()
                return
            }
            let tag = "WebviewMethod.bpn_eventCommerce"
            guard let jsonString = jsonParams  else {
                ComponentLog.e("jsonString notfound", tag:tag)
                return
            }
            let jsonData = AppUtil.getJsonParam(jsonString:jsonString) 
            guard let goodsid = jsonData?["goodsid"] as? String else {
                ComponentLog.e("goodsid notfound", tag:tag)
                return
            }
            guard let pid = jsonData?["pid"] as? String else {
                ComponentLog.e("pid notfound", tag:tag)
                return
            }
            guard let epsd_id = jsonData?["epsd_id"] as? String else {
                ComponentLog.e("epsd_id notfound", tag:tag)
                return
            }
            guard let sris_id = jsonData?["sris_id"] as? String else {
                ComponentLog.e("sris_id notfound", tag:tag)
                return
            }
            guard let synopsis_type = jsonData?["synopsis_type"] as? String else {
                ComponentLog.e("synopsis_type notfound", tag:tag)
                return
            }
            guard let ptype = jsonData?["ptype"] as? String else {
                ComponentLog.e("ptype notfound", tag:tag)
                return
            }
            guard let conTitle = jsonData?["conTitle"] as? String else {
                ComponentLog.e("conTitle notfound", tag:tag)
                return
            }
           
            guard let pidOnly = jsonData?["pidOnly"] as? String else {
                ComponentLog.e("pidOnly notfound", tag:tag)
                return
            }
            let monthlyTitle = jsonData?["monthlyTitle"] as? String
            let data = EventCommerceData(
                callback: callback,
                goodsid: goodsid, pid: pid, epsd_id: epsd_id, sris_id: sris_id,
                synopsis_type: synopsis_type, ptype: ptype, conTitle: conTitle, pidOnly: pidOnly,
                monthlyTitle: monthlyTitle)
            self.eventData = data
            
            self.dataProvider.requestData(
                q: .init(
                    id:self.tag,
                    type:.getPackageDirectView(isPpm: true, pidList: [goodsid, pid])
                )
            )
            
        
        default : break
        }
    }
    
    func respondCallFuncionEventCommerce(res:ApiResultResponds){
        guard let eventData = self.eventData as? EventCommerceData else { return }
        switch res.type {
        case .getPackageDirectView :
            guard let data = res.data as? DirectPackageView else { return }
            if let list = data.resp_directList {
                var commerce: Bool = false
                var monthly: Bool = false
                list.forEach { item in
                    if item.resp_prod_id == eventData.goodsid {
                        commerce = item.resp_direct_result?.toBool() ?? false
                    } else if item.resp_prod_id == eventData.pid {
                        monthly = item.resp_direct_result?.toBool() ?? false
                    }
                }
                if monthly {
                    if !commerce {
                        let purchaseWebviewModel = PurchaseWebviewModel()
                            .setParam(seriesId: eventData.sris_id, epsId: eventData.epsd_id)
                            .setParam(synopsisType: eventData.synopsis_type, pType: eventData.ptype,
                                      title: eventData.conTitle, pId: eventData.goodsid, pIdOnly: eventData.pidOnly)
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.purchase)
                                .addParam(key: .data, value:purchaseWebviewModel)
                        )
                        
                    } else {
                        self.appSceneObserver.alert = .alert(nil, String.alert.eventAlreadyPurchase)
                    }
                } else {
                    self.moveMonthly()
                }
                
            } else {
                guard let callback = eventData.callback else { return }
                self.viewModel.request = .evaluateJavaScriptMethod( callback, nil)
            }
        
        default: break
        }
    }
    
    func errorCallFuncionEventCommerce(err:ApiResultError) {
        guard let eventData = self.eventData as? EventCommerceData else { return }
        switch err.type {
        case .getPackageDirectView :
            guard let callback = eventData.callback else { return }
            self.viewModel.request = .evaluateJavaScriptMethod( callback, nil)
       
        default: break
        }
    }
    
    func moveMonthly(){
        guard let eventData = self.eventData as? EventCommerceData else { return }
        let leading = eventData.monthlyTitle?.removingPercentEncoding
            ?? eventData.conTitle.removingPercentEncoding
            ?? eventData.conTitle
        let msg = leading + " " + String.alert.eventJoinAndPurchase
        self.appSceneObserver.alert = .alert(nil, msg, confirmText: String.alert.eventMonthlyView){
            let band = self.dataProvider.bands.getData(gnbTypCd: EuxpNetwork.GnbTypeCode.GNB_MONTHLY.rawValue )
            //let findBlock = band?.blocks.first{$0.prd_prc_id == eventData.pid}
            self.pagePresenter.changePage(PageProvider
                                            .getPageObject(.home)
                                            .addParam(key: .id, value: band?.menuId)
                                            .addParam(key: .type, value: eventData.pid)
                                            .addParam(key: UUID().uuidString, value: "")
            )
            
        }
    }
}
