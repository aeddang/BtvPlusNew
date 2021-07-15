//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI


struct PageKidsExam: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var viewModel:KidsExamModel = KidsExamModel(type: .solve)
    @ObservedObject var soundBoxModel:SoundBoxModel = SoundBoxModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
   
  
    @State var isPairing:Bool = false
   
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                ZStack(alignment: .top){
                    VStack (alignment: .center, spacing:0){
                        if self.isPairing {
                            if self.isError {
                                ErrorKidsData()
                                    .modifier(MatchParent())
                            } else {
                                ExamBody(
                                    viewModel:self.viewModel,
                                    soundBoxModel: self.soundBoxModel,
                                    type:self.type
                                )
                                .modifier(MatchParent())
        
                            }
                            
                        } else {
                            NeedPairingInfo(
                                title: String.kidsText.kidsMyNeedPairing,
                                text: String.kidsText.kidsMyNeedPairingSub)
                                .modifier(MatchParent())
                        }
                        
                    }
                    .padding(.top, DimenKids.app.pageTop)
                    PageKidsTab(
                        title:self.title,
                        titleTip: self.titleTip,
                        titleTipColor: self.titleTopColor,
                        isBack: false,
                        isClose: true,
                        style: .kidsClear){
                        
                        self.appSceneObserver.alert = .confirm(
                            nil ,
                            self.title + String.kidsText.kidsExamCloseConfirm,
                            String.kidsText.kidsExamCloseConfirmTip
                            ){ isOk in
                            if isOk {
                                self.pagePresenter.closePopup(self.pageObject?.id)
                            }
                        }
                    }
                    
                    if self.isStart {
                        ExamEffectViewer(
                            type: self.type,
                            text: self.typeText,
                            isComplete: false
                        ){
                            withAnimation{
                                self.isStart = false
                            }
                            self.viewModel.start()
                        }
                        .modifier(MatchParent())
                    }
                    if self.isCompleted {
                        ExamEffectViewer(
                            type: self.type,
                            text: self.type == .infantDevelopment
                                ? String.kidsText.kidsExamInfantDevelopmentCompleted.replace(self.typeText ?? "")
                                : nil,
                            isComplete: true
                        ){
                            self.isAniCompleted = true
                        }
                        .modifier(MatchParent())
                    }
                }
                .background(
                    Image(AssetKids.image.homeBg)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFill()
                        .modifier(MatchParent())
                        .opacity(self.isPairing ? 0 : 1)
                )
                .modifier(PageFullScreen(style:.kids))
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
              
            }//draging
            
            .onReceive(self.pairing.$status){status in
                self.isPairing = ( status == .pairing )
            }
            .onReceive(self.pairing.$kid){ kid in
                self.kid = kid ?? Kid()
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.initPage()
                }
            }
            .onReceive(dataProvider.$result) { res in
                guard let res = res else { return }
                switch res.type {
                case .getEnglishLvReportExam, .getReadingReportExam,  .getCreativeReportExam :
                    guard let exams  = res.data as? KidsExams else { return }
                    if exams.result == ApiCode.success {
                        self.setupExam(exams)
                    } else {
                        self.appSceneObserver.alert = .alert(
                            nil ,
                            exams.reason ?? String.alert.apiErrorServer ){
                                self.pagePresenter.closePopup(self.pageObject?.id)
                        }
                    }
                   
                
                case .getEnglishLvReportQuestion, .getReadingReportQuestion,  .getCreativeReportQuestion :
                    guard let result = res.data as? KidsExamQuestionResult else {
                        self.saveError()
                        return
                    }
                    if result.result == ApiCode.success {
                        self.appSceneObserver.event = .toast(String.alert.kidExamSaveCompleted)
                        self.pagePresenter.closePopup(self.pageObject?.id)
                    } else {
                        self.saveError()
                    }
                default: break
                }
            }
            .onReceive(dataProvider.$error) { err in
                guard let err = err else { return }
                switch err.type {
                case .getEnglishLvReportExam, .getReadingReportExam,  .getCreativeReportExam :
                    self.isError = true
                case .getEnglishLvReportQuestion, .getReadingReportQuestion,  .getCreativeReportQuestion :
                    self.saveError()
                default: break
                }
            }
            .onReceive(self.viewModel.$event){evt in
                switch evt {
                case .ready : self.isStart = true
                case .quest(_ , let question ) :
                    withAnimation{
                        self.titleTip = question.targetType.name
                        self.titleTopColor = question.targetType.color
                    }
                case .complete : self.isCompleted = true
                case .completed :
                    if self.isSaveCompleted {return}
                    self.isSaveCompleted = true
                    self.saveData()
                default : break
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let type = obj.getParamValue(key: .type) as? DiagnosticReportType {
                    self.type = type
                }
                if let value = obj.getParamValue(key: .id) as? String {
                    self.value = value
                }
                if let value = obj.getParamValue(key: .text) as? String {
                    self.typeText = value
                }
                
            }
        }//geo
    }//body
    
    @State var kid:Kid = Kid()
    @State var typeText:String? = nil
    @State var type:DiagnosticReportType = .english
    @State var value:String? = nil
    @State var isError:Bool = false
    @State var title:String = ""
    @State var titleTip:String? = nil
    @State var titleTopColor:Color = Color.app.sepia
    
    @State var isStart:Bool = false
   
    @State var isCompleted:Bool = false
    
    @State var isAniCompleted:Bool = false
    @State var isSaveCompleted:Bool = false
    
    private func initPage(){
        self.isError = false
        switch self.type {
        case .english:
            self.dataProvider.requestData(q: .init(type: .getEnglishLvReportExam(kid, target: value)))
        case .infantDevelopment:
            self.dataProvider.requestData(q: .init(type: .getReadingReportExam(kid, area: value)))
        case .creativeObservation:
            self.dataProvider.requestData(q: .init(type: .getCreativeReportExam(kid)))
        }
    }
    
    private func setupExam(_ data:KidsExams){
        guard let exam  = data.contents else {
            self.isError = true
            return
        }
        self.viewModel.setData(exam, reportType: self.type)
        self.title = self.viewModel.title ?? ""
    }
    
    private func saveData(){
        switch self.type {
        case .english:
            self.dataProvider.requestData(
                q: .init(type: .getEnglishLvReportQuestion(
                            self.kid,
                            self.viewModel.epNo,
                            self.viewModel.epTpNo,
                            self.viewModel.questions)))
        case .infantDevelopment:
            self.dataProvider.requestData(
                q: .init(type: .getReadingReportQuestion(
                            self.kid,
                            self.viewModel.epNo,
                            self.viewModel.epTpNo,
                            self.viewModel.questions)))
        case .creativeObservation:
            self.dataProvider.requestData(
                q: .init(type: .getCreativeReportQuestion(
                            self.kid,
                            self.viewModel.epNo,
                            self.viewModel.epTpNo,
                            self.viewModel.questions)))
        }
    }
    
    private func saveError(){
        self.appSceneObserver.alert = .confirm( nil , String.alert.kidExamSaveError ){ isOk in
            if isOk {
                self.saveData()
            } else {
                self.pagePresenter.closePopup(self.pageObject?.id)
            }
        }
        self.pagePresenter.closePopup(self.pageObject?.id)
    }
}

#if DEBUG
struct PageKidsExam_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            PageKidsExam().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(DataProvider())
                .environmentObject(Pairing())
                .frame(width: 360, height: 680, alignment: .center)
        }
    }
}
#endif
