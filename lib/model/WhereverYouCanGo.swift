//
//   WhereverYouCanGo.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/03.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation

class IwillGo:PageProtocol{
    private static let pageID = "pageID"
    private static let pageIDX = "pageIDX"
    private static let params = "params"
    private static let isPopup = "isPopup"
    var page: PageObject? = nil
    init(with page:PageObject? = nil) {
        self.page = page
    }
    
    func stringfy()-> String?{
        guard let value = page else {
            ComponentLog.e("stringfy : page is nil", tag: self.tag)
            return nil
        }
        var dic = [String:Any]()
        dic[IwillGo.pageID] = value.pageID
        dic[IwillGo.pageIDX] = value.pageIDX
        dic[IwillGo.params] = value.params
        dic[IwillGo.isPopup] = value.isPopup
        let jsonString = AppUtil.getJsonString(dic: dic)
        return jsonString
    }
    
    func qurry()-> String?{
        guard let value = page else {
            ComponentLog.e("qurry : page is nil", tag: self.tag)
            return nil
        }
        var qurryString =
        IwillGo.pageID + "=" + value.pageID +
        "&" + IwillGo.pageIDX + "=" + value.pageIDX.description +
        "&" + IwillGo.isPopup + "=" + value.isPopup.description
        if let params = value.params {
            for (k, v) in params {
                var str = v as? String
                if str == nil {
                    str = (v as? Bool)?.description
                }
                if str == nil {
                    str = (v as? Int)?.description
                }
                qurryString += "&" + k + "=" + (str ?? "" )
            }
        }
        ComponentLog.d("qurry : " + qurryString, tag: self.tag)
        return qurryString
    }
    
    func parse(jsonString: String) -> IwillGo? {
        guard let data = jsonString.data(using: .utf8) else {
            ComponentLog.e("parse : jsonString data error", tag: self.tag)
            return nil
        }
        do{
            let value = try JSONSerialization.jsonObject(with: data , options: [])
            guard let dictionary = value as? [String: Any] else {
                ComponentLog.e("parse : dictionary error", tag: self.tag)
                return nil
            }
            return parse(dictionary: dictionary)
        } catch {
           ComponentLog.e("parse : JSONSerialization " + error.localizedDescription, tag: self.tag)
           return nil
        }
    }
    
    func parse(qurryString: String) -> IwillGo? {
        var dictionary = [String: Any]()
        var params = [String: Any]()
        for pair in qurryString.components(separatedBy: "&") {
            let key = pair.components(separatedBy: "=")[0]
            let value = pair
                .components(separatedBy:"=")[1]
                .replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding ?? ""
            switch key {
            case IwillGo.pageID: dictionary[key] = value
            case IwillGo.pageIDX: dictionary[key] = value
            case IwillGo.isPopup: dictionary[key] = value
            default:
                params[key] = value
            }
            
        }
        dictionary[ IwillGo.params ] = params
        return parse(dictionary: dictionary)
    }
    
    func parse(dictionary: [String: Any]) -> IwillGo? {
        guard let pageID = dictionary[IwillGo.pageID] as? String else {
            ComponentLog.e("parse : pageID nil error", tag: self.tag)
            return nil
        }
        let pageIDX = Int(dictionary[IwillGo.pageIDX] as? String ?? "0") ?? 0
        let params = dictionary[IwillGo.params] as? [String:Any]
        let isPopup = dictionary[IwillGo.isPopup] as? String
    
        page = PageObject(pageID: pageID, pageIDX: pageIDX, params: params, isPopup: isPopup == "true")
        ComponentLog.d("parse : " + page.debugDescription, tag: self.tag)
        return self
    }
}

struct WhereverYouCanGo {
    static func parseIwillGo(jsonString: String) -> IwillGo? {
        return IwillGo().parse(jsonString:jsonString)
    }
    static func parseIwillGo(json: [String: Any]) -> IwillGo? {
        return IwillGo().parse(dictionary: json)
    }

    static func parseIwillGo(qurryString: String) -> IwillGo? {
        return IwillGo().parse(qurryString:qurryString)
    }

    static func stringfyIwillGo( page: PageObject ) -> String?
    {
        return IwillGo(with:page).stringfy()
    }
    
    static func stringfyIwillGo(
        pageID: PageID,
        params: [String:Any]? = nil,
        isPopup: Bool = false,
        pageIDX:Int = 0
    ) -> String?
    {
        let page = PageObject(pageID: pageID, pageIDX: pageIDX, params: params, isPopup: isPopup)
        return IwillGo(with:page).stringfy()
    }
    
    static func qurryIwillGo( page: PageObject ) -> String?
    {
        return IwillGo(with:page).qurry()
    }
    
    static func qurryIwillGo(
        pageID: PageID,
        params: [String:Any]? = nil,
        isPopup: Bool = false,
        pageIDX:Int = 0
    ) -> String?
    {
        let page = PageObject(pageID: pageID, pageIDX: pageIDX, params: params, isPopup: isPopup)
        return IwillGo(with:page).qurry()
    }
    
}
