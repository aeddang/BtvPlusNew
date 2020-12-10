//
//  ComponentCircularNavigation.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/24.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct CPCircularNavigation : PageComponent {
    @ObservedObject var viewModel:NavigationModel
    @Binding var backgroundImage:String?
    @Binding var rotateImage:String?
    @Binding var buttons:[NavigationButton]
    @Binding var totalRotateIdx:Int
    @Binding var useDrag:Bool
    @State private var prevRotate = 0.0
    @State private var rotate = 0.0
    @State private var rotateRange = 0.0
    @State private var dragAmount = CGSize.zero
    private let startRotate = -180.0
    private let radiusAmount:Double = 0.45
    private let sensitivity = 0.7
    
    
    init(
        viewModel:NavigationModel,
        buttons:Binding<[NavigationButton]>,
        backgroundImage:Binding<String?>? = nil,
        rotateImage: Binding<String?>? = nil,
        totalRotateIdx:Binding<Int>? = nil,
        useDrag:Binding<Bool>? = nil
    )
    {
        self.viewModel = viewModel
        self._buttons = buttons
        self._backgroundImage = backgroundImage ?? Binding.constant(nil)
        self._rotateImage = rotateImage ?? Binding.constant(nil)
        self._totalRotateIdx = totalRotateIdx ?? Binding.constant(12)
        self._useDrag = useDrag ?? Binding.constant(true)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                if self.backgroundImage != nil {
                    Image(self.backgroundImage!)
                        .renderingMode(.original).resizable()
                }
                if self.rotateImage != nil {
                    Image(self.rotateImage!)
                        .renderingMode(.original).resizable()
                        .rotationEffect(.degrees(self.rotate - self.startRotate))
                }
                ForEach(self.buttons, id: \.id) { btn in
                    self.createButton(btn, geometry: geometry)
                }
            }
            .highPriorityGesture(self.useDrag ? DragGesture()
                .onChanged({ value in
                    self.onChanged(value: value, geometry: geometry)
                })
                .onEnded({ value in
                    self.onEnded(value: value, geometry: geometry)
                })
                : nil
            )
        }//GeometryReader
        .onAppear {
            self.rotate = self.startRotate
            self.prevRotate = self.startRotate
            self.rotateRange = 360.0 / Double( self.totalRotateIdx )
        }
    }
    
    func createButton(_ btn:NavigationButton, geometry:GeometryProxy) -> some View {
        return Button<AnyView?>(action: {
            self.performAction(btn.id)
        }){
            btn.body
        }
        .frame(width: btn.frame.width, height: btn.frame.height, alignment: .center)
        .offset(
            x: CGFloat(
                Double(geometry.size.width) * self.radiusAmount
                * cos(
                    (self.rotate + self.rotateRange * Double(btn.idx))
                    * .pi / 180)
            ),
            y: CGFloat(
                Double(geometry.size.width) * self.radiusAmount
                * sin(
                    (self.rotate + self.rotateRange * Double(btn.idx))
                    * .pi / 180)
            )
        ).animation(
            Animation.easeInOut(duration: Duration.ani.medium)
        )
    }
    
    func performAction(_ btnID:String){
        self.viewModel.selected = btnID
        ComponentLog.d("onSelected : " + btnID, tag:tag)
    }
    
    func onChanged(value:DragGesture.Value, geometry:GeometryProxy){
        let translation = value.translation
        self.dragAmount = translation
        var tRadian = atan2(translation.height, translation.width) / .pi * 180.0
        let startX = value.startLocation.x - (geometry.size.width / 2.0)
        let startY = value.startLocation.y - (geometry.size.height / 2.0)
        var sRadian = atan2(startY, startX) / .pi * 180.0
        
        sRadian = sRadian < 0 ? 360.0 + sRadian : sRadian
        tRadian = tRadian < 0 ? 360.0 + tRadian : tRadian
        let d = 90.0
        var dr = Double(tRadian - sRadian)
        if dr > d {
            dr = 180.0 - dr
        }else if dr < -d {
            dr = -180.0 - dr
        }
        let v = dr / d
        let p =  sqrt(
                    pow(Double(translation.height),2.0) +
                    pow(Double(translation.width),2.0))
                 * self.sensitivity * v
        
        //PageLog.log("tRadian : " + tRadian.description, tag: self.TAG)
        //PageLog.log("sRadian : " + sRadian.description, tag: self.TAG)
        //PageLog.log("v : " + v.description, tag: self.TAG)
        //PageLog.log("p : " + p.description, tag: self.TAG)
        self.rotate = self.prevRotate + p
    }
    
    func onEnded(value:DragGesture.Value, geometry:GeometryProxy){
        let snapIdx = round( self.rotate / self.rotateRange )
        self.rotate = snapIdx * self.rotateRange
        self.prevRotate = self.rotate
    }
}


#if DEBUG
struct CPCircularNavigation_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            CPCircularNavigation(
                viewModel:NavigationModel(),
                buttons: .constant([
                    NavigationButton(
                        id: "test1",
                        body: AnyView(
                            Text("test")
                        ),
                        idx:0
                    ),
                    NavigationButton(
                        id: "test2",
                        body: AnyView(
                            Image(Asset.test)
                            .renderingMode(.original).resizable()),
                        idx:1
                    ),
                    NavigationButton(
                        id: "test3",
                        body: AnyView(
                            Text("test")),
                        idx:2
                    ),
                    NavigationButton(
                        id: "test4",
                        body: AnyView(
                            Text("test")),
                        idx:3
                    )

                ]),
                backgroundImage: .constant(Asset.test),
                rotateImage: .constant(Asset.test))
                .frame(width: 250, height: 250, alignment: .center)
        }
    }
}
#endif


