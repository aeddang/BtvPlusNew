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
            .scaledToFit()
            .frame(
                width: DimenKids.item.profileRegist.width,
                height: DimenKids.item.profileRegist.height)
            .overlay(
               Circle()
                .stroke(
                    self.isSelected ? Color.kids.primary : Color.transparent.clear,
                    lineWidth: Dimen.stroke.regular)
            )
            //.padding(.all, DimenKids.margin.tinyExtra)
            Image(self.isSelected
                    ? AssetKids.shape.checkBoxOn
                    : AssetKids.shape.checkBoxOff)
                .renderingMode(.original).resizable()
                .scaledToFit()
                .frame(width: DimenKids.icon.light, height: DimenKids.icon.light)
                .padding(.trailing, -DimenKids.margin.tinyExtra)
                
        }
    }
}

extension PageSelectKidCharacter {
    static let key = "PageSelectKidCharacter"
    static let spacing:CGFloat = SystemEnvironment.isTablet
        ? DimenKids.margin.lightExtra : DimenKids.margin.light
}


struct PageSelectKidCharacter: PageView {
    
    @EnvironmentObject var pagePresenter:PagePresenter

    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()

    @State var characterIdx:Int = 0
    @State var boxPos:CGFloat = -300
    
    let characterSets:[CharacterRows] = CharacterRowData(
        datas: zip(0 ..< AssetKids.characterList.count, AssetKids.characterList)
            .map {index, character in CharacterData(idx:index, image:character)}).getRow(lineNum: 3)
    

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
                       
                        VStack (alignment: .center, spacing: Self.spacing){
                            ForEach(self.characterSets) { set in
                                HStack(alignment: .top, spacing: Self.spacing) {
                                    ForEach( set.cells) { data in
                                        CharacterKidItem(
                                            isSelected: self.characterIdx == data.idx,
                                            data: data)
                                            .onTapGesture {
                                                self.characterIdx = data.idx
                                            }
                                    }
                                }
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
                                self.pagePresenter.onPageEvent(
                                    self.pageObject, event: .init(id:self.tag, type: .selected, data: self.characterIdx))
                                self.pagePresenter.closePopup(self.pageObject?.id)
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
