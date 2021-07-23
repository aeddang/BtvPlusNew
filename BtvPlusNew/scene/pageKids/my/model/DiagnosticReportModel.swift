//
//  DiagnosticReport.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/07.
//

import Foundation

enum DiagnosticReportType:String, CaseIterable{
    case english ,infantDevelopment, creativeObservation, finalQuiz
    var name: String? {
        switch self {
        case .english: return String.sort.english
        case .infantDevelopment: return String.sort.infantDevelopment
        case .creativeObservation: return String.sort.creativeObservation
        default : return nil
        }
    }
    
    var startImage: String {
        switch self {
        case .english: return AssetKids.image.englishReport
        case .infantDevelopment: return AssetKids.image.infantDevelopmentReport
        case .creativeObservation: return AssetKids.image.creativeObservationReport
        default : return ""
        }
    }
    
    var startText: String {
        switch self {
        case .english: return String.kidsText.kidsMyEnglishText
        case .infantDevelopment: return String.kidsText.kidsMyInfantDevelopmentText
        case .creativeObservation: return String.kidsText.kidsMyCreativeObservationText
        default : return ""
        }
    }
    
    var startButton: String {
        switch self {
        case .english: return AssetKids.image.goLevelTest
        case .infantDevelopment: return AssetKids.image.goDevelopmentTest
        case .creativeObservation: return AssetKids.image.goCreativityTest
        default : return ""
        }
    }
    var resultButton: String {
        switch self {
        case .english: return AssetKids.image.goLevelResult
        case .infantDevelopment: return AssetKids.image.goDevelopmentResult
        case .creativeObservation: return AssetKids.image.goCreativityResult
        default : return ""
        }
    }
    
   
    var startReport: String {
        switch self {
        case .english: return String.kidsText.kidsMyEnglishReport
        case .infantDevelopment: return String.kidsText.kidsMyMyInfantDevelopmentReport
        case .creativeObservation: return String.kidsText.kidsMyCreativeObservationReport
        default : return ""
        }
    }
    
    var startBg: String {
        switch self {
        case .english: return AssetKids.exam.startBg1
        case .infantDevelopment: return AssetKids.exam.startBg2
        case .creativeObservation: return AssetKids.exam.startBg3
        case .finalQuiz: return AssetKids.exam.startBg4
        }
    }
    
    var completeBg: String {
        switch self {
        case .english: return AssetKids.exam.completeBg1
        case .infantDevelopment: return AssetKids.exam.completeBg2
        case .creativeObservation: return AssetKids.exam.completeBg3
        case .finalQuiz: return AssetKids.exam.completeBg4
        }
    }
}

class StudyData{
    public var resultSentence:String? = nil
    func setData(_ data:KidStudy){
        if let count = data.recomm_menus?.count {
            if count > 1 {
                self.resultSentence = data.recomm_menus?[1].items?.first?.test_result_sentence
            }
        }
    }
}

class DiagnosticReportModel:ObservableObject, PageProtocol{
    @Published private(set) var isUpdated:Bool = false {didSet{ if isUpdated { isUpdated = false} }}
    private(set) var kid:Kid? = nil
    private(set) var studyData:StudyData = StudyData()
    var readingArea:String? = nil
    func reset(){
        self.kid = nil
        self.studyData = StudyData()
        self.isUpdated = true
    }
    
    @discardableResult
    func setData(_ data:KidStudy, kid:Kid?) -> DiagnosticReportModel {
        self.kid = kid
        self.readingArea = nil
        self.studyData.setData(data)
        self.isUpdated = true
        return self
    }
    
    
    func updatedKid() {
        self.isUpdated = true
    }
}


struct CommentData:Identifiable{
    let id:String = UUID().uuidString
    let title:String
    let text:String
}

