//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI

struct PageHome: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PageDataProviderModel = PageDataProviderModel()
   
    @State var blocks:Array<Block> = []
    @State var menuId:String = ""
    var body: some View {
        PageDataProviderContent(
            pageObservable:self.pageObservable,
            viewModel : self.viewModel
        ){
            if self.blocks.isEmpty {
                Spacer()
            }else{
                VStack(alignment: .center)
                {
                    ForEach(self.blocks, id: \.id) {data in
                        Text(data.name)
                            .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.grey))
                    }
                }//VStack
            }
        }
        .background(Color.brand.bg)
        .onAppear{
            guard let obj = self.pageObject  else { return }
            self.menuId = (obj.getParamValue(key: .id) as? String) ?? self.menuId
            self.setupBlocks()
        }
        .onReceive(self.dataProvider.bands.$event){ evt in
            guard let evt = evt else { return }
            switch evt {
            case .updated: self.setupBlocks()
            default: do{}
            }
        }
        
    }//body
    
    private func setupBlocks(){
        guard let blocksData = self.dataProvider.bands.getData(menuId: self.menuId)?.blocks else {return}
        self.blocks = blocksData.map{ data in
            Block().setDate(data)
        }
    }
    
}


#if DEBUG
struct PageHome_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageHome().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

