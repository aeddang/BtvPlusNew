//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct PageRecommand: PageView {
   
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @State var synopsisData:SynopsisData? = nil
    var body: some View {
        ZStack(alignment: .center) {
            Button(action: {
                self.pagePresenter.closePopup(self.pageObject?.id)
            }) {
               Spacer().modifier(MatchParent())
                   .background(Color.transparent.black70)
            }
            ShareRecommand(
                synopsisData:self.synopsisData
            ){
                self.pagePresenter.closePopup(self.pageObject?.id)
            }
            .frame(width: SystemEnvironment.isTablet ? 474 : 329)
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.heavy))
        }
        .modifier(MatchParent())
        .onAppear(){
            guard let obj = self.pageObject  else { return }
            self.synopsisData = obj.getParamValue(key: .data) as? SynopsisData
           
        }
        
    }//body
    
    
   
}



#if DEBUG
struct PageRecommand_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageRecommand().contentBody
                .environmentObject(DataProvider())
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .frame(width: 420, height: 640, alignment: .center)
        }
    }
}
#endif
