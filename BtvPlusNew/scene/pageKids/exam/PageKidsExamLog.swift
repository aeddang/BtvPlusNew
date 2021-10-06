//
//  PageKidsExamLog.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/10/06.
//

import Foundation
import SwiftUI
extension PageKidsExam {

    func onExit(){
        self.naviLogManager.actionLog(.clickExitButton, pageId: self.type.logExamPage)
    }
    
    func onEvent(examEvent:ExamEvent){
        switch examEvent {
        
        case .completed :
            break
        default : break
            
        }
    }
    
    func onEvent(examRequest:ExamRequest){
        switch examRequest {
        case .next :break
        default : break
        }
    }
    func onEvent(examLogEvent:ExamLogEvent){
        switch examLogEvent {
        case .next :
            self.naviLogManager.actionLog(.clickNextButton, pageId: self.type.logExamPage, actionBody: .init(config:"다음문제"))
        case .prev :
            self.naviLogManager.actionLog(.clickNextButton, pageId: self.type.logExamPage, actionBody: .init(config:"이전문제"))
        }
    }
    
    
}
