//
//  AnimateDrawView.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/08.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

protocol AnimateDrawViewProtocol {
    var isRunning:Bool { get set }
    var isCompleted:Bool { get set }
    var isDrawing:Bool { get set }
    
    //func startAnimation(_ duration:Double, delay:Double )
    //func stopAnimation()
    func onStart()
    func onCompute(frm:Int, t:Double)
    func onComplete(frm:Int)
    func onCancel(frm:Int)
    func onDraw(frm:Int)
}

extension AnimateDrawViewProtocol {
   
    var isDrawing: Bool  { get{false} set{}}
    var isCompleted: Bool  { get{false} set{}}
    func onComplete(frm:Int){}
    func onCancel(frm:Int){}
    func onDraw(frm:Int){}
    
    @discardableResult
    func createJob( duration:Double, fps:Double) -> AnyCancellable?{
        var frm = 0
        var job:AnyCancellable? = nil
        let backgroundQueue = DispatchQueue.global(qos: .background)
        job = Timer.publish(every: fps, on:.current, in: .common)
            .autoconnect()
            .subscribe(on: backgroundQueue)
            .map{_ in
                if !self.isRunning {
                    job?.cancel()
                    self.onCancel(frm:frm)
                    return
                }
                frm += 1
                let t = fps * Double(frm)
                if frm == 1 { self.onStart() }
                self.onCompute(frm:frm, t: t)
                if duration > 0 {
                    if duration <= t {
                        self.onComplete(frm:frm)
                        job?.cancel()
                    }
                }
            }
            .receive(on:RunLoop.main)
            .sink{_ in
                if self.isDrawing { self.onDraw(frm:frm) }
            }
        return job
    }
}

/*
struct AnimateDrawView: View , AnimateDrawViewProtocol {
    @State var isRunning: Bool = false{
        didSet{
            if isRunning {
                startAnimation()
            }else{
                stopAnimation()
            }
        }
    }
    
    func startAnimation(_ duration:Double = 0, delay:Double = 0 ) {
        isRunning = true
        createJob(duration: duration, fps:fps)
    }
    func stopAnimation() {
        isRunning = false
    }
    
    func onStart() {
        //PageLog.log("onStart")
        
    }
    func onCompute(frm: Int, t:Double) {
    }
    
    func onDraw() {
    }
    
    var body: some View {
        Group{
            Rectangle().fill(Color.red).frame(width: 100, height: 100, alignment: .center)
        }.onAppear(){
           
        }.onDisappear(){
            self.stopAnimation()
        }
        
    }
    
}
#if DEBUG
struct AnimateDrawView_Previews: PreviewProvider {
    static var previews: some View {
        AnimateDrawView( isRunning:true )
    }
}
#endif
*/
