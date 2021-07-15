//
//  KidProfile.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/03.
//

import Foundation
import SwiftUI

extension ExamControl {
    static let bgSize:CGSize = SystemEnvironment.isTablet ? CGSize(width: 223, height: 667) : CGSize(width: 138, height: 365)
    static let bodySize:CGSize = SystemEnvironment.isTablet ? CGSize(width: 223, height: 667) : CGSize(width: 138, height: 307)
}

struct ExamControl: PageComponent{
    @ObservedObject var viewModel:KidsExamModel = KidsExamModel()
    @ObservedObject var soundBoxModel:SoundBoxModel = SoundBoxModel()
    var isView:Bool = false
    var body: some View {
        ZStack(alignment: .topLeading){
            Image( AssetKids.exam.answerBg)
                .renderingMode(.original).resizable()
                .scaledToFit()
                .frame(width: Self.bgSize.width, height: Self.bgSize.height)
                .padding(.top ,Self.bodySize.height - Self.bgSize.height)
            VStack( spacing: 0 ){
                SoundBox(
                    viewModel: self.viewModel,
                    soundBoxModel: self.soundBoxModel,
                    isView: self.isView
                )
                .padding(.trailing, SystemEnvironment.isTablet ? 30 : 32)
                .opacity(self.answer == -1 || isView ? 1 : 0.3)
                
                if self.question != nil {
                    if !isView {
                        AnswerBox(
                            right: self.right,
                            answer: self.answer,
                            submit:self.submit,
                            exNum: self.exCount)
                        { sumit in
                            if self.viewModel.status == .quest {
                                self.viewModel.solve(submit: sumit)
                            }
                        }
                        .padding(.top, DimenKids.margin.light)
                    } else {
                        AnswerBox(
                            right: self.right,
                            answer: self.answer,
                            submit:self.submit,
                            exNum: self.exCount)
                        .padding(.top, DimenKids.margin.light)
                    }
                }
                Spacer()
                
            }
            .frame(width: Self.bodySize.width, height: Self.bodySize.height)
            if self.viewModel.type == .solve {
                ExamResultBox(right: self.right, answer: self.answer)
                    .padding(.leading ,
                             Self.bodySize.width - ExamResultBox.size.width
                             - (SystemEnvironment.isTablet ? 28 : 32)
                    )
            }
        }
        .frame(width: Self.bodySize.width, height: Self.bodySize.height)
        .onReceive(self.viewModel.$request){evt in
            switch evt {
            case .solve(let submit) :
                withAnimation {
                    self.submit = submit
                }
            default : break
            }
        }
        .onReceive(self.viewModel.$event){evt in
            switch evt {
            case .quest(_ , let question ) :
                withAnimation {
                    self.submit = -1
                    self.exCount = question.count
                    if self.viewModel.type == .solve{
                        self.answer = -1
                        self.right = -1
                    } else {
                        self.answer = question.submit ?? -1
                        self.right = question.answer
                        
                        DataLog.d("answer right " + self.right.description, tag: self.tag)
                        DataLog.d("answer " + self.answer.description, tag: self.tag)
                    }
                }
                self.question = question
                
            case .answer(let answer) :
                withAnimation {
                    self.right = answer
                    self.answer = self.submit
                    self.soundBoxModel.isRight = self.right == self.answer
                }
               
            case .complete :
                withAnimation {
                    self.submit = -1
                    self.answer = -1
                    self.right = -1
                }
            default : break
            }
        }
        
    }
    @State var question:QuestionData? = nil
    @State var right:Int = -1
    @State var submit:Int = -1
    @State var answer:Int = -1
    @State var exCount:Int = 0

}

#if DEBUG
struct ExamControl_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            ExamControl(
               
            )
            .frame(width: 400, height: 700)
        }
    }
}
#endif
