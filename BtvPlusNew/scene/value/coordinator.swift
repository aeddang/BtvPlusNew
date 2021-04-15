//
//  Assets.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/05.
//

import Foundation
extension Dimen{
    struct item {
        static let profile:CGSize = CGSize(width: 110, height: 110)
    }
}

extension Asset{
    static let characterList = [
        "imgProfile37",
        "imgProfile38",
        "imgProfile39",
        "imgProfile40",
        "imgProfile01",
        "imgProfile02",
        "imgProfile03",
        "imgProfile04",
        "imgProfile05",
        "imgProfile06",
        "imgProfile07",
        "imgProfile08",
        "imgProfile09",
        "imgProfile10",
        "imgProfile11",
        "imgProfile12",
        "imgProfile13",
        "imgProfile14",
        "imgProfile15",
        "imgProfile16",
        "imgProfile17",
        "imgProfile18",
        "imgProfile19",
        "imgProfile20",
        "imgProfile21",
        "imgProfile22",
        "imgProfile23",
        "imgProfile24",
        "imgProfile25",
        "imgProfile26",
        "imgProfile27",
        "imgProfile28",
        "imgProfile29",
        "imgProfile30",
        "imgProfile31",
        "imgProfile32",
        "imgProfile33",
        "imgProfile34",
        "imgProfile35",
        "imgProfile36"
    ]
    
    static let brightnessList = [
        Asset.player.brightnessLv0,
        Asset.player.brightnessLv1,
        Asset.player.brightnessLv2,
        Asset.player.brightnessLv3,
        Asset.player.brightnessLv4,
        Asset.player.brightnessLv5
    ]
    
    static let volumeList = [
        Asset.player.volumeLv0,
        Asset.player.volumeLv1,
        Asset.player.volumeLv2,
        Asset.player.volumeLv3
    ]
}
