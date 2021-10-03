//
//  SynopsisViewModel.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/10/03.
//

import Foundation
enum SynopsisViewModelEvent {
    case changeVod(String?), changeSynopsis(SynopsisData?, isSrisChange:Bool = false),
         changeOption(PurchaseModel?),
         purchase, watchBtv, srisSortChanged, bookMark(Bool), like(String), share(isRecommand:Bool),
         selectPerson(PeopleData), summaryMore
}
class SynopsisViewModel:ComponentObservable{
    @Published var uiEvent:SynopsisViewModelEvent? = nil {didSet{ if uiEvent != nil { uiEvent = nil} }}
}
