//
//  ComponentTabNavigation.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine


struct CPTabNavigation : PageComponent {
    @ObservedObject var viewModel:NavigationModel = NavigationModel()
    var buttons:[NavigationButton]
    @State var index: Int = 0
    @State private var isUserScrolling: Bool = false
    @State private var offset: CGFloat = 0
    @State private var prevOffset: CGFloat = 0
    @State private var updatedIndex: Int = -1
    @State private var needGesture = false
    var spacing:CGFloat = 0
    var useSpacer = true
    var primaryColor:Color = Color.brand.primary
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing:0){
                    HStack( spacing: self.spacing ){
                        ForEach(self.buttons) { btn in
                            self.createButton(btn)
                        }
                    }
                    if self.useSpacer {
                        Spacer()
                        .frame(
                            width: self.getSpacerSize(),
                            height:Dimen.line.regular
                        )
                        .background(self.primaryColor)
                        .offset(
                            x:self.getSpacerPosition(geometry:geometry)
                        )
                        
                    }
                    Spacer()
                        .modifier(MatchHorizontal(height: Dimen.line.regular))
                        .background(Color.app.whiteDeep).opacity(0.1)
                }
                .frame(alignment: .leading)
               
            }
            .content
            .offset(x:self.offset)
            .modifier(MatchParent())
            .clipped()
            .highPriorityGesture(
                DragGesture()
                    .onChanged({ value in
                        if !self.needScroll(contentWidth: self.getContentSize(), geometry: geometry) { return }
                        self.isUserScrolling = true
                        self.offset = self.prevOffset + value.translation.width
                        
                        //ComponentLog.d("DragGesture " + self.offset.description, tag:self.tag)
                    })
                    .onEnded({ value in
                        let size = self.getContentSize()
                        if !self.needScroll(contentWidth: size, geometry: geometry) { return }
                        withAnimation{
                            self.offset = self.getScrollOffset(
                                contentWidth:size,
                                willOffset:self.offset,
                                geometry:geometry)
                        }
                        self.prevOffset = self.offset
                        self.isUserScrolling = false
                    })
            )
            .onReceive( self.viewModel.$index ){ idx in
                if self.index == idx {return}
                withAnimation{ self.index = idx }
            }
            .onAppear(){
                self.index = self.viewModel.index
            }
        }//GeometryReader
            
    }
    
    func createButton(_ btn:NavigationButton) -> some View {
        return Button<AnyView?>(
            action: { self.performAction(btn.id, index: btn.idx)}
        ){
            btn.body
        }
        .frame(
            width: btn.frame.width,
            height: btn.frame.height
        )
    }
    
    func needScroll(contentWidth:CGFloat, geometry:GeometryProxy) -> Bool {
        return contentWidth > geometry.size.width
    }
    
    func getContentSize() -> CGFloat {
        if self.buttons.isEmpty {return 0}
        return self.buttons.reduce(-spacing, {sum, btn  in btn.frame.width + sum + spacing})
    }
    func getSpacerSize() -> CGFloat {
        if self.buttons.isEmpty {return 0}
        return self.buttons[self.index].frame.width
    }
    
    func getScrollOffset(contentWidth:CGFloat, willOffset:CGFloat, geometry:GeometryProxy) -> CGFloat {
        let range = (contentWidth - geometry.size.width) / 2.0
        if(contentWidth <= geometry.size.width) { return range }
        if(willOffset > 0) { return 0 }
        if abs(willOffset) > range {
            return willOffset/abs(willOffset)*range
        }else{
            return willOffset
        }
    }
    
    func getSpacerPosition(geometry:GeometryProxy) -> CGFloat {
        let contentWidth = self.getContentSize()
        let startPos = contentWidth / 2.0
        let btnSize = self.getSpacerSize() / 2.0
        var pos:CGFloat = 0
        if self.index < 1 { pos = btnSize - startPos }
        else{
            let max = self.index - 1
            pos = self.buttons[0...max].reduce(
                0,
                {sum, btn  in
                    btn.frame.width + sum + spacing})
                - startPos + btnSize
        }
        
        if self.updatedIndex != self.index {
            let posOffset = self.getScrollOffset(
                contentWidth:contentWidth,
                willOffset:-pos,
                geometry:geometry)
            DispatchQueue.main.async {
                self.prevOffset = posOffset
                withAnimation{
                    self.offset = posOffset
                }
                self.updatedIndex = self.index
            }
            
        }
        return pos
    }
    
    func performAction(_ btnID:String, index:Int){
        self.viewModel.selected = btnID
        self.viewModel.index = index
        withAnimation{
            self.index = index
        }
        ComponentLog.d("performAction : " + index.description, tag:tag)
    }
    
}


#if DEBUG
struct CPTabNavigation_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            CPTabNavigation(
                buttons: [
                    NavigationButton(
                        id: "test1sdsd",
                        body: AnyView(
                            Text("testqsq").background(Color.yellow)
                        ),
                        idx:0
                    ),
                    NavigationButton(
                        id: "test2",
                        body: AnyView(
                            Image(Asset.test).renderingMode(.original).resizable()
                                .frame(width: 100, height: 10)
                        ),
                        idx:1
                    ),
                    NavigationButton(
                        id: "test3",
                        body: AnyView(
                            Text("tesdcdcdvt")
                        
                        ),
                        idx:2
                    ),
                    NavigationButton(
                        id: "test4",
                        body: AnyView(
                            Text("te")
                            
                        ),
                        idx:3
                    )

                ]
            )
            .frame( alignment: .center)
            .background(Color.brand.bg)
        }
    }
}
#endif
