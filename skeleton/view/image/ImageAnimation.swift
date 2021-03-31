//
//  ImageView.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/10.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct ImageAnimation : View, AnimateDrawViewProtocol, PageProtocol {
    var images:[String] = []
    var contentMode:ContentMode  = .fit
    var fps:Double = 0.33
    @Binding var isRunning: Bool
    @State var isDrawing: Bool = false
    @State var currentFrm:Int = 0
   
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
        createJob(duration: 0, fps: 0.05)
    }
    func stopAnimation() {
        //ComponentLog.d("stopAnimation" , tag: self.tag)
        isDrawing = false
        currentFrm = 0
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
}


