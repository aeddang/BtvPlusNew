//
//  ImageConst.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/14.
//

import Foundation
import SwiftUI

//    -. URL 포맷
//       [domain]:[port][root_path]/[width]_[height]_[filter]/[file_path]
//
//    -. filter 옵션값
//       변환 옵션 = CROP : 20 / EXTENSION : 30
//       위치 옵션 =  CENTER : 0 / TOP : 1 / BOTTOM : 2 / LEFT : 4 / RIGHT : 8
//       blur 옵션 = B20

struct ImagePath {
    static func imagePath(
        filePath: String?,
        size: CGSize = CGSize(width: 0,height: 0),
        convType: IIPConvertType = .none,
        locType: IIPLocType = .none,
        server:ApiServer = .IIP) -> String?{
        if filePath == nil || filePath == "" {return nil}
        
        let path = ApiPath.getRestApiPath(server) + "/"
        return getIIPUrl(path: path, filePath: filePath ?? "", size: size, convType: convType, locType: locType)
    }
    
    static func thumbImagePath(
        filePath: String?,
        size: CGSize = CGSize(width: 0,height: 0),
        convType: IIPConvertType = .none,
        locType: IIPLocType = .none,
        server:ApiServer = .IIP) -> String? {
        
        if filePath == nil || filePath == "" {return nil}
        let path = ApiPath.getRestApiPath(server)
        let apiPath = "/thumbnails/iip/"
        return getIIPUrl(path: path + apiPath, filePath: filePath ?? "", size: size, convType: convType, locType: locType)
    }

    static func getIIPUrl(path:String, filePath: String, size: CGSize, convType: IIPConvertType = .none, locType: IIPLocType = .none) -> String {
        let scale = UIScreen.main.scale
        let width = size.width * scale
        let height = size.height * scale
        var str = ""
        switch convType {
        case .crop, .extension:
            str = "_\(convType.rawValue)"
            if locType != .none {
                let conv:Int = Int(convType.rawValue) ?? 0
                str = "_\(conv + locType.rawValue)"
            }
        case .alpha, .blur:
            str = "_\(convType.rawValue)"
        default:break
        }
        return ("\(path)\(Int(width))_\(Int(height))\(str)\(filePath)")
    }
}

enum IIPConvertType: String {
    case none = "0"
    case crop = "20"
    case `extension` = "30"
    case alpha = "A20"
    case blur = "B20"
}

enum IIPLocType: Int {
    case none = -1
    case center = 0
    case top = 1
    case bottom = 2
    case left = 4
    case right = 8
}
