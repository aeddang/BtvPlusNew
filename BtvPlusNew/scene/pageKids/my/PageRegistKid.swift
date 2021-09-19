//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI


struct PageRegistKid: PageView {
    enum EditType {
        case nickName, birth, none
    }
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var setup:Setup
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()

    @State var editType:EditType = .none
    @State var nickName:String = ""
    @State var characterIdx:Int = 0
    @State var birthDate:Date = Date()
    @State var birth:String = String.app.birthKidsPlaceholder
    @State var boxPos:CGFloat = -100
    @State var isInitBirthSelect:Bool = false
    
    @State var isFocus:Bool = false
    @State var isRegistUnvisible:Bool = false
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                ZStack(alignment: .center){
                    VStack (alignment: .center, spacing:0){
                        Text(String.kidsText.registKidTitle)
                            .modifier(BoldTextStyleKids(size: Font.sizeKids.regular, color: Color.app.brown))
                            .fixedSize(horizontal: false, vertical: true)
                        Text(String.kidsText.registKidText)
                            .multilineTextAlignment(.center)
                            .modifier(BoldTextStyleKids(size: Font.sizeKids.thinExtra, color: Color.app.brown))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, DimenKids.margin.tiny)
                        Spacer().modifier(LineHorizontal(color: Color.app.black))
                            .padding(.top, DimenKids.margin.tiny)
                        HStack(alignment: .top, spacing: DimenKids.margin.heavy) {
                            VStack(spacing:DimenKids.margin.thin){
                                Text(String.kidsText.registKidCharacter)
                                    .multilineTextAlignment(.center)
                                    .modifier(BoldTextStyleKids(size: Font.sizeKids.lightExtra, color: Color.app.brown))
                                    .fixedSize(horizontal: false, vertical: true)

                                Button(action: {
                                    self.selectCharacter()
                                }) {
                                    Image(AssetKids.characterList[self.characterIdx])
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: DimenKids.item.profileRegist.width,
                                               height: DimenKids.item.profileRegist.height)
                                }
                            }
                            VStack(alignment: .leading, spacing:DimenKids.margin.thin){
                                InputCellKids(
                                    title: String.app.nickNameKids,
                                    input: self.$nickName,
                                    isFocus: self.isFocus,
                                    placeHolder: String.app.nickNameHolderKids,
                                    strokeColor: Color.transparent.clear
                                ){
                                   
                                }
                                .frame(width: SystemEnvironment.isTablet ? 357 : 186)
                                InputCellKids(
                                    title: self.isInitBirthSelect
                                        ? String.app.birthKids
                                        : String.app.birthKidsPlaceholder,
                                    input: self.$birth,
                                    inputFontSize:Font.sizeKids.large,
                                    isFocus: self.editType == .birth,
                                    strokeColor: Color.transparent.clear,
                                    isEditable : false,
                                    kern: Font.kern.thin
                                ){
                                    
                                }
                                .frame(width: SystemEnvironment.isTablet ? 278 : 150)
                                .onTapGesture {
                                    self.selectBirth()
                                }
                            }
                        }
                        .padding(.top, DimenKids.margin.light)
                        HStack(spacing:DimenKids.margin.thin){
                            Button(action: {
                                self.toggleRegistUnvisible()
                            }) {
                                Image(
                                    self.isRegistUnvisible
                                        ? AssetKids.shape.checkBoxOn2
                                        :AssetKids.shape.checkBoxOff2)
                                    .renderingMode(.original)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: DimenKids.icon.tiny,
                                           height: DimenKids.icon.tiny)
                            }
                            Text(String.app.weekUnvisible)
                                .multilineTextAlignment(.center)
                                .modifier(BoldTextStyleKids(size: Font.sizeKids.tiny, color: Color.app.brownLight))
                                .fixedSize(horizontal: false, vertical: true)
                            
                        }
                        .padding(.top, Dimen.margin.medium)
                        HStack(spacing:DimenKids.margin.thin){
                            RectButtonKids(
                                text: String.app.cancel,
                                isSelected: false
                            ){idx in
                                self.pagePresenter.closePopup(self.pageObject?.id)
                            }
                            RectButtonKids(
                                text: String.kidsTitle.registKidCreate,
                                isSelected: true,
                                size: DimenKids.button.heavyRect
                            ){idx in
                                self.registKid()
                            }
                            .opacity(self.isInputCompleted() ? 1.0 : 0.3)
                        }
                        .padding(.top, Dimen.margin.medium)
                    }
                    .padding(.all, DimenKids.margin.mediumExtra)
                    .background(Color.app.ivory)
                    .frame(width: SystemEnvironment.isTablet ? 957 : 490)
                    .clipShape(RoundedRectangle(cornerRadius: DimenKids.radius.heavy))
                    .padding(.bottom, self.boxPos)
                    
                }
                .modifier(MatchParent())
                .padding(.horizontal, DimenKids.margin.heavy)
                .background( Color.transparent.black70 )
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }//draging
            .onTapGesture {
                AppUtil.hideKeyboard()
            }
            .onReceive(dataProvider.$result) { res in
                guard let res = res else { return }
                if res.id != self.tag { return }
                switch res.type {
                default: break
                }
            }
            .onReceive(dataProvider.$error) { err in
                guard let err = err else { return }
                if err.id != self.tag { return }
                switch err.type {
                default: break
                }
            }
            .onReceive(self.pagePresenter.$event){ evt in
                guard let evt = evt else {return}
                if evt.id != PageSelectKidCharacter.key {return}
                switch evt.type {
                case .selected :
                    guard let selectIdx = evt.data as? Int else { return }
                    self.characterIdx = selectIdx
                default : break
                }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    withAnimation{
                        self.boxPos = 0
                    }
                }
            }
            .onReceive(self.keyboardObserver.$isOn){ on in
                if self.pageObservable.layer != .top { return }
                self.updatekeyboardStatus(on:on)
            }
            .onReceive(self.pairing.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .updatedKids(let updateType) :
                    guard let type = updateType else {return}
                    var msg:String = ""
                    switch type {
                    case .post : msg = String.alert.kidsAddCompleted
                    case .put : msg = String.alert.kidsEditCompleted
                    case .del : msg = String.alert.kidsDeleteCompleted
                    }
                    self.appSceneObserver.event = .toast(msg) 
                    self.pagePresenter.closePopup(self.pageObject?.id)
                    break
                case .notFoundKid :
                    self.appSceneObserver.alert = .alert(nil, String.alert.kidsProfileNotfound )
                    self.pagePresenter.closePopup(self.pageObject?.id)
                    break
                case .editedKidsError(let updateType) :
                    if updateType == .post {
                        self.appSceneObserver.alert = .alert(nil,String.alert.kidsAddError)
                    }
            
                default : break
                }
            }
            .onAppear{
                self.birthYear = self.birthDate.toDateFormatter(dateFormat: "yyyy" + String.app.year)
                self.birthMonth = self.birthDate.toDateFormatter(dateFormat: "MM" + String.app.month)
                self.birth = self.birthYear + " " + self.birthMonth
                
            }
           
            
        }//geo
    }//body
    
    private func isInputCompleted() -> Bool {
        var complete = false
        if !self.nickName.isEmpty {
            complete = true
        }
        return complete
    }
    
    private func updatekeyboardStatus(on:Bool) {
        withAnimation{
            self.editType = on
                ? .nickName
                : self.editType == .nickName ? .none : self.editType
            self.boxPos = on
                ? 100 : 0
        }
        
        if self.isFocus != on {
            self.isFocus = on
        }
        
    }
    
    private func selectCharacter() {
        withAnimation{
            self.editType = .none
        }
        AppUtil.hideKeyboard()
        self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.selectKidCharacter))
        
    }
    
    private let birthYearList = (1900...2100).map{
        $0.description + String.app.year
    }
    private let birthMonthList = (1...12).map{
        $0.description.toFixLength(2) + String.app.month
    }
    
    @State private var birthYear:String = ""
    @State private var birthMonth:String = ""
    private func selectBirth() {
        withAnimation{
            self.editType = .birth
        }
        AppUtil.hideKeyboard()
        let picYear = self.birthYearList.firstIndex(of: self.birthYear) ?? 0
        let picMonth = self.birthMonthList.firstIndex(of: self.birthMonth) ?? 0
        self.appSceneObserver.select =
            .multiPicker((self.tag, [self.birthYearList, birthMonthList]), [picYear,picMonth])
            { idxYear, idxMonth, _, _ in
                self.isInitBirthSelect = true
                self.birthYear = self.birthYearList[idxYear]
                self.birthMonth = self.birthMonthList[idxMonth]
                self.birth = self.birthYear + " " + self.birthMonth
                self.birthDate = self.birth.toDate(
                    dateFormat: "yyyy" + String.app.year + "MM" + String.app.month) ?? Date()
                
                withAnimation{
                    self.editType = .none
                }
            }
    }
    
    
    private func toggleRegistUnvisible() {
        self.isRegistUnvisible.toggle()
        if self.isRegistUnvisible {
            self.setup.kidsRegistUnvisibleDate = Setup.getDateKey()
        } else {
            self.setup.kidsRegistUnvisibleDate = ""
        }
        
    }
    
    private func registKid() {
        if !self.isInputCompleted() {return}
        if !self.nickName.isNickNameType() {
            self.appSceneObserver.alert = .alert(nil, String.alert.kidsInvalidNickName)
            return
        }
        let age = self.birthDate.toDateFormatter(dateFormat: "yyyy").toInt()
        let current = Date().toDateFormatter(dateFormat: "yyyy").toInt()
        let ageCount = (current - age)
        if ageCount >= Kid.LIMITED_AGE {
            self.appSceneObserver.alert = .alert(nil, String.alert.kidsInvalidBirth)
            return
        }else if ageCount < 0 {
            self.appSceneObserver.alert = .alert(nil, String.alert.kidsWrongBirth)
            return
        }
        let kid = Kid(nickName: self.nickName, characterIdx: self.characterIdx, birthDate: self.birthDate)
        self.pairing.requestPairing(.registKid(kid))
        
    }
   
}

#if DEBUG
struct PageRegistKid_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            PageRegistKid().contentBody
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
