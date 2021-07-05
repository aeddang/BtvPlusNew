//
//  EvaluationReport.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/05.
//

import Foundation
struct EvaluationExams: Decodable {
    private(set) var contents: EvaluationExam? 
}
struct EvaluationExam: Decodable {
    private(set) var sris_id: String? //
}
