//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI


enum PrerollRequest {
    case load(SynopsisPrerollData), play
}

enum PrerollEvent {
    case event(OneAdEvent), finish
}
class PrerollModel: ComponentObservable, Identifiable{
    @Published var request:PrerollRequest? = nil{ willSet{ self.status = .update } }
    @Published fileprivate(set) var event:PrerollEvent? = nil
}

extension Preroll{
    static var isInit = false
    static func initate(){
        let mediaId = "cfb87121-4f7b-4d88-99ff-2b446c00e1c4"
        let accessKey = "8LrhdsQYra5WG/o15zaCpsKz9uyy/WuqT2qTqo2oix340pJIxMFFwx+7smR8iEsL"
        OneAdSdk.initialize(withMediaId: mediaId, accessKey: accessKey)
       
        if SystemEnvironment.isTestMode {
            OneAdSdk.setEnvironment( .PROD )
            OneAdSdk.setDebug(true)
        }else{
            OneAdSdk.setEnvironment( SystemEnvironment.isStage ? .STAGE : .PROD)
            OneAdSdk.setDebug(false)
        }
        Self.isInit = true
    }
}

struct Preroll: UIViewRepresentable, PageProtocol {
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @ObservedObject var viewModel: PrerollModel = PrerollModel()
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> OneAdView {
        let uiView = OneAdView(frame: .zero)
        uiView.delegate = context.coordinator
        //ComponentLog.d("Preroll viewModel " + self.viewModel.id , tag: self.tag)
        //ComponentLog.d("Preroll uiView init", tag: self.tag)
        //uiView.backgroundColor = .blue
        //uiView.setProgressImageResource("loadingImage.Bundle/loading_big_1.png")
        return uiView
    }
    func updateUIView(_ uiView: OneAdView, context: Context) {
        if self.viewModel.status != .update { return }
        switch viewModel.request {
        case .load(let data):
            var params = [String:String]()
            params["placementId"] = "btvplus/vod-preroll"
            
            var extParams = [String:String]()
            extParams["contentId"] = data.contentId
            extParams["isFree"] = data.isFree ? "true" : "false"
            extParams["startType"] = data.type.adCode
            
            ComponentLog.d("Preroll load " + data.contentId , tag: self.tag)
            ComponentLog.d("Preroll load " + data.isFree.description , tag: self.tag)
            ComponentLog.d("Preroll load " + data.type.adCode , tag: self.tag)

            uiView.params = params
            uiView.extParams = extParams
            uiView.prepareAd()
            
        case .play:
            uiView.playAd()
        default:do{}
        }
    }
    
    class Coordinator: NSObject, OneAdEventDelegate {
        let parent: Preroll
        init(_ parent: Preroll) {
            self.parent = parent
        }
        
        func handle(_ event: OneAdEvent!) {
            //self.parent.viewModel.event = .event(event)
            //ComponentLog.d("Preroll event " + event.debugDescription, tag: self.parent.tag)
            switch event.eventType {
            case .ClickAd: do{}
            case .CloseLandingPage: do{}
            case .DidReceiveAd:
                
                self.parent.viewModel.request = .play
                
            case .FailReceiveAd,
                 .NotExistReceiveAd,
                 .FinishAd,
                 .SkipAd,
                 .StopAd:
                
                self.parent.viewModel.event = .finish
            
            default: do{}
            }
        }
    }
}

#if DEBUG
struct Preroll_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            Preroll(
               
            )
            .environmentObject(PagePresenter())
            .modifier(MatchParent())
        }
        .background(Color.brand.bg)
    }
}
#endif
