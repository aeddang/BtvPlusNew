//
//  KidsExamModel.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/09.
//
import Foundation
import Combine

enum ExamRequest{
    case start, solve(Int), next, prev
}

enum ExamEvent{
    case ready(Int), quest(Int, QuestionData), answer(Int), hold(Int), complete, completed
}

enum ExamStatus:String{
    case initate, quest, hold, complete
}

enum ExamType:String{
    case view, solve, evaluation
}

class KidsExamModel:ObservableObject, PageProtocol{
    @Published private(set) var request:ExamRequest? = nil {didSet{ if request != nil { request = nil} }}
    @Published private(set) var event:ExamEvent? = nil {didSet{ if event != nil { event = nil} }}
    @Published private(set) var status:ExamStatus = .initate
    
    private var holdSubscription:AnyCancellable?
    
    private(set) var reportType:DiagnosticReportType = .english
    private(set) var type:ExamType = .solve
    private(set) var title:String? = nil
    private(set) var epNo:String? = nil
    private(set) var epTpNo:Int? = nil
    private(set) var questions:[QuestionData] = []
    private(set) var step:Int = 0
    private(set) var stepComplete:Int = 0
    private(set) var holdCount:Int = 0
    private(set) var holdComplete:Int = 3
    init(type:ExamType = .solve) {
        self.type = type
    }
    
    deinit {
        self.holdCancel()
    }
    
    @discardableResult
    func setData(_ data:KidsExam, reportType:DiagnosticReportType) -> KidsExamModel {
        self.reportType = reportType
        switch reportType {
        case .english : self.type = .solve
        case .infantDevelopment : self.type = .evaluation
        case .creativeObservation : self.type = .evaluation
        }
        self.title = data.ep_tit_nm
        self.epNo = data.ep_no?.string
        self.epTpNo = data.ep_tp_no?.number?.toInt()
        if let items = data.q_items {
            self.questions = items.map{QuestionData().setData($0)}
        }
        self.reset()
        self.event = .ready(self.stepComplete)
        DataLog.d("ready " + self.stepComplete.description, tag: self.tag)
        return self
    }
    
    @discardableResult
    func setData(title:String?, questions:[QuestionData], reportType:DiagnosticReportType) -> KidsExamModel {
        self.reportType = reportType
        self.type = .view
        self.title = title ?? self.reportType.name
        self.questions = questions
        self.reset()
        self.event = .ready(self.stepComplete)
        DataLog.d("ready " + self.stepComplete.description, tag: self.tag)
        return self
    }
    
    private func reset(){
        self.step = 0
        self.stepComplete = self.questions.count - 1
    }
    func start(){
        self.reset()
        self.request = .start
        DataLog.d("start", tag: self.tag)
        self.next(0)
    }
    
    func move(_ diff:Int){
        if self.status != .quest {return}
        DataLog.d("move " + diff.description, tag: self.tag)
        self.next(diff)
        
    }
    
    func solve(submit:Int){
        if self.status != .quest {return}
        let question = self.questions[self.step]
        question.submit = submit
        self.request = .solve(submit)
        DataLog.d("solve " + submit.description, tag: self.tag)
        if self.type == .solve {
            self.holdComplete = 4
            self.hold()
        } else {
            self.holdComplete = 0
            self.hold()
        }
    }
    
    private func next(_ diff:Int = 1){
        self.holdCancel()
        let nextStep = self.step + diff
        if nextStep > self.stepComplete {
            self.complete()
        } else {
            self.step = nextStep
            self.status = .quest
            self.event = .quest(self.step, self.questions[self.step])
            DataLog.d("quest " + self.step.description , tag: self.tag)
        }
    }
    private func holdCancel(){
        self.holdSubscription?.cancel()
        self.holdSubscription = nil
        self.holdCount = 0
    }
    private func hold(){
        self.holdCancel()
        if self.status != .complete {
            self.status = .hold
        }
        holdSubscription = Timer.publish(
            every: 0.2, on: .main, in: .common)
            .autoconnect()
            .sink() {_ in
                if self.holdCount == self.holdComplete {
                    if self.status == .complete {
                        self.event = .completed
                    } else {
                        self.next()
                    }
                    
                } else {
                    if self.status == .hold {
                        if self.holdCount == 0 {
                            self.answer()
                        } else {
                            let h = self.holdCount-1
                            self.event = .hold(h)
                            DataLog.d("hold " + h.description, tag: self.tag)
                        }
                    } else {
                        self.event = .hold(self.holdCount)
                        DataLog.d("hold " + self.holdCount.description, tag: self.tag)
                    }
                    self.holdCount += 1
                }
        }
    }
    
    private func answer(){
        let question = self.questions[self.step]
        self.event = .answer(question.answer)
        DataLog.d("answer " + question.answer.description, tag: self.tag)
    }
    
    
    private func complete(){
        self.status = .complete
        self.event = .complete
        DataLog.d("complete", tag: self.tag)
        if self.type != .view {
            self.holdComplete = 3
            self.hold()
        }
    }
}
