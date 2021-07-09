//
//  QuestionData.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/09.
//

import Foundation
import SwiftUI

enum QuestionTargetType{
    case parents, kids, unowned(String?)
    
    static func setType(_ value:String?) -> QuestionTargetType {
        switch value {
        case "31" : return .parents
        case "32": return .kids
        default : return .unowned(value)
        }
    }
    
    var code:String {
        get {
            switch self {
            case .parents: return "31"
            case .kids: return "32"
            case .unowned(let cd): return cd ?? ""
            }
        }
    }
    var color:Color {
        get {
            switch self {
            case .parents: return Color.app.sepia
            case .kids: return Color.app.yellow
            case .unowned : return Color.app.sepia
            }
        }
    }

    var name:String? {
        get {
            switch self {
            case .parents: return String.kidsText.kidsExamForParent
            case .kids: return String.kidsText.kidsExamForkid
            case .unowned : return nil
            }
        }
    }
}

class QuestionData:Identifiable{
    let id:String = UUID().uuidString
    private(set) var data:KidsExamQuestion? = nil
    private(set) var audioPath:String? = nil
    private(set) var imagePath:String? = nil
    private(set) var answer:Int = -1
    private(set) var count:Int = 0
    private(set) var targetType:QuestionTargetType = .unowned(nil)
    
    var submit:Int? = nil
    
    var submitCode:Int {
        get{
            guard let submit = self.submit else { return 0}
            return submit + 1
        }
    }
  
    func setData(_ data:KidsExamQuestion) -> QuestionData {
        self.data = data
        self.targetType = QuestionTargetType.setType(data.tgt_per_cd)
        if let audio = data.q_aud_url {
            if !audio.hasSuffix(".mp3") {
                self.audioPath = audio + ".mp3"
            } else {
                self.audioPath = audio
            }
        }
        self.imagePath = ImagePath.thumbImagePath(filePath: data.q_img_url, size: CGSize(width: 320, height: 0), convType: .alpha)
        self.count = data.q_ex_cnt ?? 0
        if let value = data.subm_ansr_cn {
            self.submit = value.toInt() - 1
        }
        if let value = data.q_cans_cn {
            self.answer = value.toInt() - 1
        }
        return self
    }
    
    func getSaveData() -> [String:Any] {
        var question = [String:Any]()
        if let q = self.data {
            question[ "q_id" ] = q.q_id
            question[ "q_sort_or" ] = q.q_sort_or
            question[ "q_bdlt_tp_cd" ] = q.q_bdlt_tp_cd
            question[ "q_cans_cn" ] = q.q_cans_cn
            question[ "q_img_url" ] = q.q_img_url
            question[ "q_aud_url" ] = q.q_aud_url
            question[ "q_ex_cnt" ] = q.q_ex_cnt
            question[ "tgt_per_cd" ] = q.tgt_per_cd
        }
        question[ "subm_ansr_cn" ] = self.submitCode
        return question
    }
    
}
