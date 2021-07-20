//
//  Euxp.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/09.
//

import Foundation
struct WebNetwork : Network{
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath(.WEB)
}

extension WebNetwork{
    static let RESPONSE_FORMET = "json"
   
    static let PAGE_COUNT = 30
    
    
   
}

class Web: Rest{
    func getSearchKeywords(
        completion: @escaping (SearchKeyword) -> Void, error: ((_ e:Error) -> Void)? = nil){
        fetch(route: WebSearchKeywords(), completion: completion, error:error)
    }
    func getCompleteKeywords(
        word:String?, type:PageType = .btv,
        completion: @escaping (CompleteKeyword) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String:String]()
        params["word"] = word ?? ""
        if type == .btv {
            fetch(route: WebCompleteKeywords(query:params), completion: completion, error:error)
        }else {
            fetch(route: WebKidsCompleteKeywords(query:params), completion: completion, error:error)
        }
        
    }
    
    func getSearchVod(
        word:String?, type:PageType = .btv,
        completion: @escaping (SearchCategory) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String:String]()
        params["word"] = word ?? ""
        if type == .btv {
            fetch(route: WebSeachVod(query:params), completion: completion, error:error)
        }else {
            fetch(route: WebKidsSeachVod(query:params), completion: completion, error:error)
        }
    }
    
    func getSeachPopularityVod(
        completion: @escaping (SearchPopularityVod) -> Void, error: ((_ e:Error) -> Void)? = nil){
        fetch(route: WebSeachPopularityVod(), completion: completion, error:error)
    }
    
}




struct WebSearchKeywords:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/api/v3.0/search/recommend/2"
}

struct WebCompleteKeywords:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/api/v3.0/search/autocomplete/word"
   var query: [String : String]? = nil
}

struct WebSeachVod:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/api/v3.0/search/word"
   var query: [String : String]? = nil
}

struct WebSeachPopularityVod:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/api/v3.0/search/popular"
}

struct WebKidsCompleteKeywords:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/api/v3.0/searchZemkids/autocomplete/word"
   var query: [String : String]? = nil
}

struct WebKidsSeachVod:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/api/v3.0/searchZemkids/word"
   var query: [String : String]? = nil
}



