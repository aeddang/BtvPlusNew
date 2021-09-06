//
//  VoiceRecorder.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/19.
//

import Foundation
import SwiftUI
extension VoiceRecorderKids {
    static let aniSize:CGFloat = SystemEnvironment.isTablet ? 414 : 218
}

struct VoiceRecorderKids: PageComponent {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var networkObserver:NetworkObserver
    
   
    var cancle: (() -> Void)
    var action: ((_ keyword:String?) -> Void)
   
    @State var isRecording:Bool = false
    @State var isError:Bool = false
    @State var bottomImage:String = AssetKids.image.voiceRecord
    @State var statusText:String = String.voice.searchTextKids
    var body: some View {
        ZStack(){
            if self.isError {
                Image(AssetKids.icon.micOn)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: DimenKids.icon.heavyExtra, height: DimenKids.icon.heavyExtra)
                    .padding(.bottom, DimenKids.margin.regular)
            } else {
                if self.isRecording {
                    ImageAnimation(images: AssetKids.ani.record, isRunning:.constant(true))
                        .frame(width: Self.aniSize, height: Self.aniSize)
                        .padding(.bottom, DimenKids.margin.regular)
                } else {
                    ImageAnimation(images: AssetKids.ani.mic, isRunning:.constant(true))
                        .frame(width: Self.aniSize, height: Self.aniSize)
                        .padding(.bottom, DimenKids.margin.regular)
                }
            }
            VStack{
                Text(self.statusText)
                    .modifier(BoldTextStyleKids(size: Font.sizeKids.medium, color: Color.app.brownDeep))
                    .padding(.top, DimenKids.margin.regular)
                Spacer()
                Image(self.bottomImage)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(height:SystemEnvironment.isTablet ? 285 : 139)
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
            //ComponentLog.d("stat " + stat.rawValue, tag: self.tag)
            switch stat {
            case .initate :
                self.isRecording = false
                if !self.isError {
                    self.repository.voiceRecognition.start()
                }
            case .ready :
                self.isRecording = false
                self.isError = false
                self.statusText = String.voice.searchTextKids
                self.bottomImage = AssetKids.image.voiceRecord
                self.repository.voiceRecognition.search()
                
            case .searching :
                self.isRecording = true
                self.statusText = String.voice.searchingTextKids
                self.bottomImage = AssetKids.image.voiceMic
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
                self.bottomImage = AssetKids.image.voiceError
                self.isRecording = false
                self.isError = true
            case .permissionError :
                cancle()
                
            case .find(let word):
                let findKeyword = word.replace("0", with: "").replace(" ", with: "")
                self.statusText = findKeyword
                action(findKeyword)
            default : break
            }
        }
        .onDisappear(){
            self.isRecording = false
            self.repository.voiceRecognition.stop()
        }
    }//body
}


#if DEBUG
struct VoiceRecorderKids_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            VoiceRecorderKids(
                cancle:{
                    
                }
            ){ keyword in
                
            }
        }
        .frame(width: 320)
        .background(Color.brand.bg)
    }
}
#endif
