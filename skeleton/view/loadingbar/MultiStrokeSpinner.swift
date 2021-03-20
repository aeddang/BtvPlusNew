//
//   MultiStrokeSpinner.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/08.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct MultiStrokeSpinner: View , AnimateDrawViewProtocol {
    @State var isLoading: Bool = false{
        didSet{
            if isLoading {
                startAnimation()
            }else{
                stopAnimation()
            }
        }
    }
    @State var isRunning = false
    
    func startAnimation(_ duration:Double = 0, delay:Double = 0 ) {
        isRunning = true
        createJob(duration: duration, fps: 0.2)
    }
    func stopAnimation() {
        isRunning = false
    }
    
    func onStart() {
    
    }
    func onCompute(frm: Int, t:Double) {
        
    }
    
    var body: some View {
        Group{
            Rectangle().fill(Color.red).frame(width: 100, height: 100, alignment: .center)
            
        }.onAppear(){
           self.isLoading = true
            
        }.onDisappear(){
           self.isLoading = false
        }
        
    }
    
}
#if DEBUG
struct MultiStrokeSpinner_Previews: PreviewProvider {
    static var previews: some View {
        MultiStrokeSpinner(isLoading:true)
    }
}
#endif

