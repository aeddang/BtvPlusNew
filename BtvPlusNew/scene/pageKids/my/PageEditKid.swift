//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI


struct PageEditKid: PageView {
    enum EditType {
        case nickName, birth, none
    }
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
   
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()

    @State var isEdit:Bool = false
    @State var editKid:Kid? = nil
    @State var editType:EditType = .none
   
     
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                
                VStack (alignment: .center, spacing:0){
                    PageKidsTab(
                        title:self.isEdit ? String.kidsTitle.editKid : String.kidsTitle.registKid,
                        isBack: true,
                        isSetting: true)
                        
                    HStack(alignment: .center, spacing: 0) {
                        VStack(spacing:DimenKids.margin.thin){
                            Spacer()
                            Text(String.kidsText.registKidCharacter)
                                .multilineTextAlignment(.center)
                                .modifier(BoldTextStyleKids(size: Font.sizeKids.lightExtra, color: Color.app.brown))
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
                            Spacer()
                        }
                        .padding(.horizontal, DimenKids.margin.heavyUltra)
                        
                        Spacer().modifier(
                            LineVertical(
                                width: DimenKids.line.regular,
                                color: Color.app.ivoryDeep, opacity: 1.0))
                            .padding(.vertical, DimenKids.margin.light)
                        
                        VStack(alignment: .leading, spacing:DimenKids.margin.light){
                            if self.isEdit {
                                HStack{
                                    Spacer()
                                    Button(action: {
                                        self.deleteKidCheck()
                                    }) {
                                        Image(AssetKids.icon.profileDelete)
                                            .renderingMode(.original)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height:  DimenKids.icon.tinyExtra)
                                    }
                                    .padding(.top, DimenKids.margin.light)
                                    .padding(.trailing, DimenKids.margin.light)
                                }
                            }
                            Spacer()
                            InputCellKids(
                                title: String.app.nickNameKids,
                                input: self.$nickName,
                                isFocus: self.editType == .nickName,
                                placeHolder: String.app.nickNameHolderKids
                            )
                            .frame(width: SystemEnvironment.isTablet ? 357 : 186)
                            
                            VStack(alignment: .leading, spacing:DimenKids.margin.tinyExtra){
                                Text(String.app.birthKids)
                                    .modifier(BoldTextStyleKids(size: Font.sizeKids.thin, color:Color.app.brown))
                                    .multilineTextAlignment(.leading)
                                HStack(alignment: .center, spacing:DimenKids.margin.micro){
                                    Text(self.birthYear)
                                        .modifier(BoldTextStyleKids(size: Font.sizeKids.large, color:Color.kids.primary))
                                        
                                    Text(String.app.year)
                                        .modifier(BoldTextStyleKids(size: Font.sizeKids.light, color:Color.app.sepia))
                                     
                                    Text(self.birthMonth)
                                        .modifier(BoldTextStyleKids(size: Font.sizeKids.large, color:Color.kids.primary))
                                       
                                    Text(String.app.month)
                                        .modifier(BoldTextStyleKids(size: Font.sizeKids.light, color:Color.app.sepia))
                                        
                                }
                                .onTapGesture {
                                    self.selectBirth()
                                }
                            }
                            Spacer()
                        }
                        .padding(.leading, DimenKids.margin.medium)
                        .modifier(MatchParent())
                    }
                    .background(Color.app.white)
                    .clipShape(RoundedRectangle(cornerRadius: DimenKids.radius.light))
                    .modifier(MatchVertical(width: SystemEnvironment.isTablet ? 960 : 500))
                    .padding(.top, DimenKids.margin.light)
                   
                    HStack(spacing:DimenKids.margin.thin){
                        RectButtonKids(
                            text: String.app.cancel,
                            isSelected: false,
                            size: DimenKids.button.mediumRectExtra
                        ){idx in
                            self.pagePresenter.closePopup(self.pageObject?.id)
                        }
                        RectButtonKids(
                            text: self.isEdit ? String.button.modify : String.button.regist2,
                            isSelected: true,
                            size: DimenKids.button.mediumRectExtra
                        ){idx in
                            self.registKid()
                        }
                        .opacity(self.isInputCompleted() ? 1.0 : 0.3)
                    }
                    .padding(.top, Dimen.margin.light)
                    .padding(.bottom, DimenKids.margin.light + self.sceneObserver.safeAreaBottom)
                }
               
                .background(
                    Image(AssetKids.image.homeBg)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFill()
                        .modifier(MatchParent())
                        
                )
                .modifier(PageFullScreen(style:.kids))
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
              
            }//draging
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
                case .editedKids :
                    self.appSceneObserver.event = .toast(String.alert.kidsEditCompleted)
                    self.pagePresenter.closePopup(self.pageObject?.id)
                    break
                
                case .notFoundKid :
                    self.appSceneObserver.alert = .alert(nil, String.alert.kidsProfileNotfound )
                    self.pagePresenter.closePopup(self.pageObject?.id)
                    break
                
                case .editedKidsError(let updateType) :
                    var msg:String = ""
                    switch updateType {
                    case .post : msg = String.alert.kidsAddError
                    case .put : msg = String.alert.kidsEditError
                    case .del : msg = String.alert.kidsDeleteError
                    default: return
                    }
                    self.appSceneObserver.alert = .alert(nil,msg)
            
                default : break
                }
            }
            .onReceive(self.pagePresenter.$event){ evt in
                guard let evt = evt else {return}
                
                switch evt.type {
                case .completed :
                    guard let type = evt.data as? PageKidsConfirmType else { return }
                    switch type {
                    case .deleteKid:
                        self.deleteKid()
                    default : break
                    }
               
                default : break
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
               
                if let kid = obj.getParamValue(key: .data) as? Kid{
                    self.isEdit = true
                    self.editKid = kid
                    self.nickName = kid.nickName
                    self.characterIdx = kid.characterIdx
                    self.birthDate =  kid.birth.toDate(dateFormat: "yyyyMM")
                    if let birthDate = self.birthDate {
                        self.birthYear = birthDate.toDateFormatter(dateFormat: "yyyy")
                        self.birthMonth = birthDate.toDateFormatter(dateFormat: "MM")
                    }
                } else {
                    self.birthDate = Date()
                    if let birthDate = self.birthDate {
                        self.birthYear = birthDate.toDateFormatter(dateFormat: "yyyy")
                        self.birthMonth = birthDate.toDateFormatter(dateFormat: "MM")
                    }
                }
            }
        }//geo
    }//body
    
    @State var nickName:String = ""
    @State var characterIdx:Int = 0
    @State var birthDate:Date? = nil
    @State private var birthYear:String = "0000"
    @State private var birthMonth:String = "00"
    
    private func isInputCompleted() -> Bool {
        var complete = false
        if self.nickName.isNickNameType() && self.birthDate != nil {
            complete = true
        }
        return complete
    }
    
    private func selectCharacter() {
        withAnimation{
            self.editType = .none
        }
        AppUtil.hideKeyboard()
        self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.selectKidCharacter))
        
    }
    
    private let birthYearList = AppUtil.getYearRange(len: 13, offset:0).map{
        $0.description + String.app.year
    }
    
    private let birthMonthList = (1...12).map{
        $0.description.toFixLength(2) + String.app.month
    }
    
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
                self.birthYear = self.birthYearList[idxYear].replace(String.app.year, with: "")
                self.birthMonth = self.birthMonthList[idxMonth].replace(String.app.month, with: "")
                let birth = self.birthYear + self.birthMonth
                self.birthDate = birth.toDate(
                    dateFormat: "yyyyMM")
                
                withAnimation{
                    self.editType = .none
                }
            }
    }
    
    private func deleteKidCheck() {
        self.appSceneObserver.alert = .confirm(nil, String.alert.kidsDeleteConfirm, String.alert.kidsDeleteConfirmTip){ isOk in
            if !isOk { return }
            self.pagePresenter.openPopup(
                PageKidsProvider.getPageObject(.kidsConfirmNumber)
                    .addParam(key: .type, value: PageKidsConfirmType.deleteKid)
            )
        }
    }
    
    private func deleteKid() {
        guard let kid = self.editKid else {
            return
        }
        self.pairing.requestPairing(.deleteKid(kid))
      
    }
    private func registKid() {
        if !self.isInputCompleted() {return}
        if let kid = self.editKid {
            if let _ = self.pairing.kids.filter({ $0.id != kid.id }).first(where: {$0.nickName == self.nickName}){
                self.appSceneObserver.event = .toast(String.alert.kidsDuplicationNickError)
                return
            }
            kid.update(
                ModifyUserData(
                    nickName: self.nickName,
                    birth: self.birthYear + self.birthMonth ,
                    characterIdx: self.characterIdx
                )
            )
            self.pairing.requestPairing(.modifyKid(kid))
        }else{
            if let _ = self.pairing.kids.first(where: {$0.nickName == self.nickName}){
                self.appSceneObserver.event = .toast(String.alert.kidsDuplicationNickError)
                return
            }
            let kid = Kid(nickName: self.nickName, characterIdx: self.characterIdx, birthDate: self.birthDate)
            self.pairing.requestPairing(.registKid(kid))
            
        }
        
    }
   
}

#if DEBUG
struct PageEditKid_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            PageEditKid().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(DataProvider())
                .environmentObject(Pairing())
                .frame(width: 360, height: 680, alignment: .center)
        }
    }
}
#endif
