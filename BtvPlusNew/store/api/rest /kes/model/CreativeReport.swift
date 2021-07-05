//
//  CreativeReport.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/05.
//

import Foundation

struct CreativeReport: Decodable {
    private(set) var contents: CreativeReportContents?
}

struct CreativeReportContents: Decodable {
    private(set) var parents: [Int]?
    private(set) var childs: [Int]?
    private(set) var labels: [String]?
}
