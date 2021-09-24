//
//  CustomPicker.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/09/24.
//

import Foundation
import SwiftUI
import Combine
struct CustomPicker: PageComponent{
    var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    var set: SelectBtnDataSet
    var selected:Int
    var textModifier:TextModifier = MediumTextStyle(size: Font.size.light).textModifier
    
    var verticalMargin:CGFloat = Dimen.margin.heavyUltra
    var bgColor:Color = Color.app.blueDeep
    var selectBgColor:Color = Color.app.blueLight
    
    var tabHeight:CGFloat = Dimen.tab.regular
    
   
    let action: (Int) -> Void

    @State var currentIdx:Int = -1
    var body: some View {
        ZStack(){
            Spacer()
                .modifier(MatchHorizontal(height:self.tabHeight))
                .background(self.selectBgColor)
                 
            InfinityScrollView(
                viewModel: self.infinityScrollModel,
                axes: .vertical,
                showIndicators:false,
                marginVertical: 0,
                marginHorizontal: 0,
                spacing: 0,
                isRecycle:true,
                useTracking: true,
                useTopButton:false
            ){

                Spacer()
                    .modifier(MatchHorizontal(height: self.tabHeight))
                    .id(UUID().hashValue)
                    
                Spacer()
                    .modifier(MatchHorizontal(height: self.tabHeight))
                    .id(UUID().hashValue)
                   
                
                ForEach(set.datas) { btn in
                    
                    Text(btn.title)
                        .font(.custom(textModifier.family, size: textModifier.size))
                        .foregroundColor(textModifier.color)
                    .id(btn.hashId)
                    .modifier(MatchHorizontal(height: self.tabHeight))
                    
                }
                
                Spacer()
                    .modifier(MatchHorizontal(height: self.tabHeight))
                    .id(UUID().hashValue)
                   
                Spacer()
                    .modifier(MatchHorizontal(height: self.tabHeight))
                    .id(UUID().hashValue)
                    
                
               
            }
            VStack(spacing:0){
                LinearGradient(
                    gradient:Gradient(colors: [self.bgColor, self.bgColor.opacity(0)]),
                    startPoint: .top, endPoint: .bottom)
                    .modifier(MatchHorizontal(height:  self.verticalMargin))
                Spacer()
                LinearGradient(
                    gradient:Gradient(colors: [self.bgColor.opacity(0), self.bgColor]),
                    startPoint: .top, endPoint: .bottom)
                    .modifier(MatchHorizontal(height:  self.verticalMargin))
            }
            .allowsHitTesting(false)
        }
        .frame(
            height: SystemEnvironment.isTablet ? 260 : 190
        )
        .onAppear(){
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.isReady = true
                ComponentLog.d("onUpdate Ready ", tag: self.tag)
            }
        }
        .onDisappear(){
           
            self.delayScrollCancel()
        }
        .onReceive(self.infinityScrollModel.$scrollPosition){_ in
            self.onUpdate()
        }
    }
    
    
    @State var isReady:Bool = false

    private func onUpdate(){
        if !self.isReady {return}
        let pos = self.infinityScrollModel.scrollPosition
        var cpos = -Int(round(pos/self.tabHeight))
        cpos = max(0, cpos)
        cpos = min(self.set.datas.count-1, cpos)
        ComponentLog.d("onUpdate " + cpos.description, tag: self.tag)
        if cpos != self.currentIdx {
            withAnimation{
                self.currentIdx  = cpos
            }
        }
        self.delayScroll()
        
    }
    
    @State var delayScrollSnap:AnyCancellable?
    func delayScroll(){
        if !self.isReady {return}
        self.delayScrollSnap?.cancel()
        self.delayScrollSnap = Timer.publish(
            every: 0.2, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.delayScrollCancel()
                let select = set.datas[self.currentIdx]
                self.infinityScrollModel.uiEvent = .scrollMove(select.hashId, .center)
                self.action(self.currentIdx)
            }
    }
    
    func delayScrollCancel(){
        self.delayScrollSnap?.cancel()
        self.delayScrollSnap = nil
    }
}
