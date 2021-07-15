//
//  ImageView.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/10.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import AVKit
import AudioToolbox
struct ImageAnimation : View, AnimateDrawViewProtocol, PageProtocol {
    var images:[String] = []
    var sound:String? = nil
    var contentMode:ContentMode  = .fit
    var fps:Double = 0.05
    var isLoof:Bool = true
    @Binding var isRunning: Bool
    @State var isDrawing: Bool = false
    @State var currentFrm:Int = 0
   
    var completed:(()->Void)? = nil
    var body: some View {
        if self.images.isEmpty {
            Spacer()
        } else {
            Image(self.images[self.currentFrm])
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: self.contentMode)
            .onReceive( [self.isRunning].publisher ) { value in
                if value == isDrawing { return }
                value ? startAnimation() : stopAnimation()
            }
            .onAppear(){
            }
            .onDisappear(){
                self.isRunning = false
            }
        }
    }
    
    func startAnimation() {
        //ComponentLog.d("startAnimation" , tag: self.tag)
        isDrawing = true
        playSound()
        createJob(duration: isLoof ? 0 : fps*Double(images.count) , fps: self.fps)
        
        
    }
    func stopAnimation() {
        //ComponentLog.d("stopAnimation" , tag: self.tag)
        isDrawing = false
    }
    func onComplete(frm:Int){
        if !isLoof {
            self.isRunning = false
            self.completed?()
        }
    }
    
    func onStart() {
        //ComponentLog.d("onStart" , tag: self.tag)
    }
    func onCancel(frm: Int) {
        //ComponentLog.d("onCancel" , tag: self.tag)
    }
    
    func onCompute(frm: Int, t:Double) {}
    func onDraw(frm: Int) {
        self.currentFrm = frm % self.images.count
        //ComponentLog.d("onDraw " + self.currentFrm.description, tag: self.tag)
    }
    
    private func playSound(){
        guard let snd = self.sound  else {return}
        SoundToolBox().play(snd: snd)
        
    }
}


