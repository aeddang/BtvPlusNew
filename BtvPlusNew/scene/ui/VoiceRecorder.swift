//
//  VoiceRecorder.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/19.
//

import Foundation
import SwiftUI
extension VoiceRecorder {
    static let height:CGFloat = 258
}

struct VoiceRecorder: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var networkObserver:NetworkObserver
    
    var title:String = String.voice.searchTitle
    var text:String = String.voice.searchText
    var action: ((_ keyword:String) -> Void)
    @State var isRecording:Bool = false
    @State var isError:Bool = false
    @State var statusText:String? = nil
    var body: some View {
        ZStack(){
            if self.isError {
                Image(Asset.icon.micError)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 258, height: Self.height)
            } else {
                ImageAnimation(images: Asset.ani.mic, isRunning: self.$isRecording)
                    .frame(width: 258, height: Self.height)
            }
            VStack{
                Text(self.title)
                    .modifier(BoldTextStyle(size: Font.size.medium, color: Color.brand.primary))
                Spacer()
                ZStack(){
                    if self.isRecording {
                        ImageAnimation(images: Asset.ani.record, isRunning: self.$isRecording)
                            .modifier(MatchHorizontal(height: 34))
                    }else if let statusText = self.statusText {
                        Text(statusText)
                            .modifier(BoldTextStyle(size: Font.size.medium, color: Color.app.white))
                        
                    }else {
                        Text(text)
                            .modifier(BoldTextStyle(size: Font.size.medium, color: Color.app.white))
                    }
                    
                }
            }
        }
        .onReceive(self.networkObserver.$status){ stat in
            if !self.isError {return}
            switch stat {
            case .wifi, .cellular :
                self.isError = false
                self.repository.voiceRecognition.start()
            default : break
            }
        }
        .onReceive(self.repository.voiceRecognition.$status){ stat in
            switch stat {
            case .initate :
                self.isRecording = false
                if !self.isError {
                    self.repository.voiceRecognition.start()
                }
            case .ready :
                self.isRecording = false
                self.isError = false
                self.statusText = nil
                self.repository.voiceRecognition.search()
                
            case .searching : self.isRecording = true
            }
        }
        .onReceive(self.repository.voiceRecognition.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .error :
                if self.isError {return}
                if self.networkObserver.status == .none {
                    self.statusText = String.alert.networkError
                } else {
                    self.statusText = String.alert.apiErrorServer
                }
                self.isRecording = false
                self.isError = true
                
            case .find(let word):
                action(word)
            default : break
            }
        }
        .onAppear(){
        }
        .onDisappear(){
            self.isRecording = false
            self.repository.voiceRecognition.stop()
        }
    }//body
}


#if DEBUG
struct EVoiceRecorder_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            VoiceRecorder(
            ){ keyword in
                
            }
        }
        .frame(width: 320)
        .background(Color.brand.bg)
    }
}
#endif
