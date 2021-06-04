//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct CharacterKidItem: PageView {
    var isSelected: Bool = false
    var data:CharacterData
    var body: some View {
        ZStack(alignment: .bottomTrailing){
            Image(data.image)
            .renderingMode(.original)
            .resizable()
            .frame(
                width: ListItem.character.size.width,
                height: ListItem.character.size.height)
            .overlay(
               Circle()
                .stroke(
                    self.isSelected ? Color.kids.primary : Color.transparent.clear,
                    lineWidth: Dimen.stroke.regular)
            )
            
            Image(self.isSelected
                    ? AssetKids.shape.checkBoxOn
                    : AssetKids.shape.checkBoxOff)
                .renderingMode(.original).resizable()
                .scaledToFit()
                .frame(width: DimenKids.icon.light, height: DimenKids.icon.light)
        }
    }
}




struct PageSelectKidCharacter: PageView {
    
    @EnvironmentObject var pagePresenter:PagePresenter

    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()

    @State var characterIdx:Int = 0
    @State var boxPos:CGFloat = -100
    
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                ZStack(alignment: .center){
                    VStack (alignment: .center, spacing:DimenKids.margin.regularExtra){
                        Text(String.kidsText.registKidCharacterText)
                            .modifier(BoldTextStyleKids(size: Font.sizeKids.lightExtra, color: Color.app.brownLight))
                            .fixedSize(horizontal: false, vertical: true)
                       
                        VStack (alignment: .center, spacing: DimenKids.margin.light){
                            HStack(alignment: .top, spacing: DimenKids.margin.light) {
                                
                            }
                        }
                        HStack(spacing:DimenKids.margin.thin){
                            RectButtonKids(
                                text: String.app.cancel,
                                isSelected: false
                            ){idx in
                                self.pagePresenter.closePopup(self.pageObject?.id)
                            }
                            RectButtonKids(
                                text: String.button.regist,
                                isSelected: true
                            ){idx in
                                
                            }
                        }

                    }
                    .padding(.all, DimenKids.margin.mediumExtra)
                    .background(Color.app.ivory)
                    .clipShape(RoundedRectangle(cornerRadius: DimenKids.radius.heavy))
                    .padding(.bottom, self.boxPos)
                }
                .modifier(MatchParent())
                .padding(.horizontal, DimenKids.margin.heavy)
                .background( Color.transparent.black50 )
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }//draging
            
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    withAnimation{
                        self.boxPos = 0
                    }
                }
            }
            
            .onAppear{
                
            }
           
            
        }//geo
    }//body
    
  
   
}

#if DEBUG
struct PageSelectKidCharacter_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            PageSelectKidCharacter().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(KeyboardObserver())
                .environmentObject(Pairing())
                .frame(width: 360, height: 680, alignment: .center)
        }
    }
}
#endif
