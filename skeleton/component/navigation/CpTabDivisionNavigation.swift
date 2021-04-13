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


struct CPTabDivisionNavigation : PageComponent {
    @ObservedObject var viewModel:NavigationModel = NavigationModel()
    var buttons:[NavigationButton]
    var useSpacer = true
    var primaryColor:Color = Color.brand.primary
    @State var index: Int = 0
    @State var pos:CGFloat = 0
   
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom){
                VStack(spacing:0){
                    HStack(spacing:0){
                        ForEach(self.buttons) { btn in
                            self.createButton(btn)
                        }
                    }
                    if self.useSpacer {
                        Spacer()
                            .frame(
                                width: self.getButtonSize(geometry: geometry),
                                height:Dimen.line.medium
                            )
                            .background(self.primaryColor)
                            .offset(
                                x: self.getButtonPosition(idx:self.index, geometry: geometry)
                            )
                    }
                }
                Spacer()
                    .modifier(MatchHorizontal(height: Dimen.line.regular))
                    .background(Color.app.whiteDeep).opacity(0.1)
            }
            .modifier(MatchParent())
            .onReceive( self.viewModel.$index ){ idx in
                if self.index == idx {return}
                withAnimation{ self.index = idx }
            }
            .onAppear(){
                self.index = self.viewModel.index
            }
        }//geo
    }//body
    
    func createButton(_ btn:NavigationButton) -> some View {
        return Button<AnyView?>(
            action: { self.performAction(btn.id, index: btn.idx)}
        ){ btn.body }
        .modifier(MatchHorizontal(height: btn.frame.height))
        .buttonStyle(BorderlessButtonStyle())
    }
    
    
    
    func getButtonSize(geometry:GeometryProxy) -> CGFloat {
        return geometry.size.width / CGFloat(self.buttons.count)
    }
    
    func getButtonPosition(idx:Int, geometry:GeometryProxy) -> CGFloat {
        let size = getButtonSize(geometry: geometry)
        return size * CGFloat(idx) + size/2.0 - ( geometry.size.width / 2.0 )
    }
    
    func performAction(_ btnID:String, index:Int){
        self.viewModel.selected = btnID
        
        withAnimation{
            self.index = index
        }
        self.viewModel.index = index
    }
    
    func getSpacerSize() -> CGFloat {
        if self.buttons.isEmpty {return 0}
        return self.buttons[self.index].frame.width
    }
}


#if DEBUG
struct CPTabDivisionNavigation_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            CPTabDivisionNavigation(
                viewModel:NavigationModel(),
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
        }
    }
}
#endif
