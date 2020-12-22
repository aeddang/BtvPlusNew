//
//  PageSample.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/10.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct PageSample: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appObserver:AppObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @State var index: Int = 0
   
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing:0){
                Text("sample")
            }
        }//geo
        .modifier(PageFull())
        .onAppear{
            
        }
    }//body
}


#if DEBUG
struct PageSample_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageSample().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(Repository())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif


