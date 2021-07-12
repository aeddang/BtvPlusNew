//
//  KidProfile.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/03.
//

import Foundation
import SwiftUI
import AVKit


extension SoundBox {
    static let size:CGSize =
        SystemEnvironment.isTablet ? CGSize(width: 218, height: 100) : CGSize(width: 124, height: 60)
}

struct SoundBox: PageComponent{
    @ObservedObject var viewModel:KidsExamModel = KidsExamModel()
    @ObservedObject fileprivate var soundBoxModel:SoundBoxModel = SoundBoxModel()
    var isView:Bool = false
    var body: some View {
        ZStack(alignment: .leading){
            Image( AssetKids.exam.listenBg)
                .renderingMode(.original).resizable()
                .scaledToFit()
                .modifier(MatchParent())
                .opacity(self.isPlayAble ? 1.0 : 0.0)
            ZStack{
                if self.isPlayAble {
                    Button(action: {
                        guard let player = self.audioPlayer else {return}
                        if player.isPlaying {
                            player.pause()
                        } else {
                            player.play()
                        }
                    }) {
                        HStack( spacing: DimenKids.margin.tiny ){
                            Image( AssetKids.exam.sound)
                                .renderingMode(.original).resizable()
                                .scaledToFit()
                                .frame(
                                    width: DimenKids.icon.regular,
                                    height: DimenKids.icon.regular)
                                .opacity(self.isPlay ? 1.0 : 0.7)
                            Text(self.isView
                                    ? String.kidsText.kidsExamRepeat
                                    : String.kidsText.kidsExamListen)
                                .kerning(Font.kern.thin)
                                .modifier(BoldTextStyleKids(
                                            size: Font.sizeKids.thin,
                                        color:  Color.app.brownDeep))
                        }
                    }
                } else {
                    Spacer()
                }
            }
            .padding(.leading, DimenKids.margin.tiny)
            .padding(.bottom, DimenKids.margin.thin)
        }
        .frame(width: Self.size.width, height: Self.size.height)
        
        .onReceive(self.viewModel.$event){evt in
            switch evt {
            case .quest(_ , let question ) :
                if let path = question.audioPath {
                    self.playSound(soundUrl: path)
                } else {
                    unableSound()
                    self.stopSound()
                    
                }
                
            default : break
            }
        }
        .onReceive(self.soundBoxModel.$isCompleted){isCompleted in
            self.isPlay = !isCompleted
        }
        .onAppear(){
            self.audioDelegate.parent = self
        }
        .onDisappear(){
            self.stopSound()
            self.setAudioSession(isActive: false)
        }
    }
    @State var isPlay:Bool = false
    @State var isPlayAble:Bool = false
    @State var audioPlayer:AVAudioPlayer? = nil
    private let audioDelegate = AudioDelegate()
    
    private func playSound(soundUrl: String)
    {
        self.stopSound()
       
        ComponentLog.d("playSound path: \(soundUrl)", tag: self.tag)
        if let url = URL(string:soundUrl) {
            self.setAudioSession(isActive: true)
            DispatchQueue.global(qos: .background).async {
                do{
                    let data = try Data(contentsOf: url)
                    let audioPlayer = try AVAudioPlayer(data: data)
                    self.audioPlayer = audioPlayer
                    audioPlayer.prepareToPlay()
                    audioPlayer.delegate = self.audioDelegate
                    if !self.isView {
                        audioPlayer.play()
                    } 
                    DispatchQueue.main.async {
                        ableSound()
                    }
                } catch let error {
                    ComponentLog.e("playSound error: \(error.localizedDescription)", tag: self.tag)
                    DispatchQueue.main.async {
                        unableSound()
                    }
                }
            }
        } else {
            unableSound()
        }
    }
    private func setAudioSession(isActive:Bool){
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
            try audioSession.setActive(isActive)
            
        } catch let error as NSError {
            ComponentLog.e("audioSession setup error: \(error.localizedDescription)", tag: self.tag)
        }
    }
    
    private func ableSound()
    {
        withAnimation{
            self.isPlayAble = true
        }
        self.isPlay = true
    }
    
    private func unableSound()
    {
        self.setAudioSession(isActive: false)
        withAnimation{
            self.isPlayAble = false
        }
        self.isPlay = false
    }
    
    private func stopSound()
    {
        self.audioPlayer?.delegate = nil
        self.audioPlayer?.stop()
        self.audioPlayer = nil
        self.isPlay = false
    }
}


class SoundBoxModel:ObservableObject, PageProtocol{
    @Published fileprivate var isCompleted:Bool = false
}
class  AudioDelegate:NSObject, AVAudioPlayerDelegate {
    fileprivate var parent: SoundBox? = nil
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.parent?.soundBoxModel.isCompleted = true
    }
}


#if DEBUG
struct SoundBox_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            SoundBox(
              
            )
        }
    }
}
#endif