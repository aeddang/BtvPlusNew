//
//  PageComponentProtocol.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/10.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation

enum ComponentStatus:String {
    case initate,
    active,
    passive ,
    ready ,
    update,
    complete ,
    error,
    end
}

open class ComponentObservable: ObservableObject , PageProtocol, Identifiable{
    @Published var status:ComponentStatus = ComponentStatus.initate
    public let id = UUID().description
}

protocol PageComponent : PageView{}
extension PageComponent {
    var pageID:PageID{
        get{ pageObservable.pageObject?.pageID ?? UUID.init().uuidString}
    }
}
