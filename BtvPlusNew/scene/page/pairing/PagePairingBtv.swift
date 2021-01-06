//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct PagePairingBtv: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    
    @State var input:String = ""
    @State var safeAreaBottom:CGFloat = 0
    @State var isInput = false
    @State var isFocus = false
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: .constant(String.pageTitle.connectCertificationBtv),
                        isClose: true
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    InfinityScrollView( viewModel: self.infinityScrollModel ){
                        if !self.isInput {
                            VStack(alignment:.leading , spacing:0) {
                                Text(String.pageText.pairingBtvText1)
                                    .modifier(MediumTextStyle( size: Font.size.bold ))
                                    .padding(.top, Dimen.margin.light)
                                Text(String.pageText.pairingBtvText2)
                                    .modifier(MediumTextStyle( size: Font.size.light ))
                                    .padding(.top, Dimen.margin.regular)
                                Text(String.pageText.pairingBtvText3)
                                    .modifier(MediumTextStyle( size: Font.size.thin ))
                                Text(String.pageText.pairingBtvText4)
                                    .modifier(MediumTextStyle( size: Font.size.thin ))
                                Text(String.pageText.pairingBtvText5)
                                    .modifier(MediumTextStyle( size: Font.size.thin ))
                                
                            }
                            .padding(.vertical, Dimen.margin.regularExtra)
                            .padding(.horizontal, Dimen.margin.regular)
                        }else{
                            Spacer().frame(height:Dimen.margin.regularExtra)
                        }
                        VStack(alignment:.center , spacing:Dimen.margin.regularExtra) {
                            Image(Asset.source.pairingTutorial)
                                .renderingMode(.original)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height:200)
                                
                            HStack(alignment:.center, spacing:Dimen.margin.light){
                                Text(String.app.certificationNumber)
                                    .modifier(BoldTextStyle(size: Font.size.light))
                                VStack(alignment: .center, spacing:0){
                                    FocusableTextField(
                                        keyboardType: .numberPad, returnVal: .done,
                                        placeholder: String.app.certificationNumberHolder,
                                        textModifier: BoldTextStyle( size: Font.size.black ).textModifier,
                                        isfocusAble: self.$isFocus,
                                        inputChanged: { text in
                                            self.input = text
                                        },
                                        inputCopmpleted: { text in
                                            self.isFocus = false
                                        })
                        
                                    Spacer().modifier(MatchHorizontal(height: 1))
                                        .background(Color.app.white)
                                }
                                .frame(width:173)
                            }
                        }
                        .modifier(MatchParent())
                        
                    }
                    .modifier(MatchParent())
                    .onTapGesture {
                        self.isFocus = false
                    }
                    FillButton(
                        text: String.button.connect,
                        isSelected: self.isInputCompleted()
                    ){_ in
                        
                        self.inputCompleted()
                    }
                    .padding(.bottom, self.safeAreaBottom)
                }
                .highPriorityGesture(
                    DragGesture(minimumDistance: 20, coordinateSpace: .local)
                        .onChanged({ value in
                            self.pageDragingModel.uiEvent = .drag(geometry, value)
                        })
                        .onEnded({ _ in
                            self.pageDragingModel.uiEvent = .draged(geometry)
                        })
                )
                .onReceive(self.infinityScrollModel.$event){evt in
                    guard let evt = evt else {return}
                    switch evt {
                    case .down, .up :
                        self.pageDragingModel.uiEvent = .pulled(geometry)
                    case .pullCancel :
                        self.pageDragingModel.uiEvent = .pulled(geometry)
                    default : do{}
                    }
                }
                .onReceive(self.infinityScrollModel.$pullPosition){ pos in
                    self.pageDragingModel.uiEvent = .pull(geometry, pos)
                }
                .modifier(PageFull())
            }
            
            .onReceive(self.sceneObserver.$safeAreaBottom){ pos in
                if self.isInput {return}
                self.safeAreaBottom = pos
            }
            .onReceive(self.keyboardObserver.$isOn){ on in
                withAnimation{
                    self.isInput = on
                    if self.isFocus != on { self.isFocus = on }
                    self.safeAreaBottom = on
                        ? self.keyboardObserver.keyboardHeight : self.sceneObserver.safeAreaBottom
                }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.isFocus = true
                }
            }
            .onAppear{
                
            }
            .onDisappear{
            }
            
        }//geo
    }//body
    
    func isInputCompleted() -> Binding<Bool> {
        return  Binding<Bool>(
            get: {
                self.input.isCertificationNumberType()
            },
            set: { _ in }
        )
    }
    
    func inputCompleted() {
        if !self.isInputCompleted().wrappedValue { return }
        
    }

}

#if DEBUG
struct PagePairingBtv_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePairingBtv().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(SceneObserver())
                .environmentObject(KeyboardObserver())
                .environmentObject(Pairing())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
