import Foundation
import SwiftUI
import Combine

class BroadcastManager : PageProtocol{
    
    private let pairing:Pairing
    private let dataProvider:DataProvider
    private var anyCancellable = Set<AnyCancellable>()
    private var dataCancellable = Set<AnyCancellable>()
    init(pairing:Pairing, dataProvider:DataProvider) {
        self.pairing = pairing
        self.dataProvider = dataProvider
    }

    func setup(){
        let broadcasting:Broadcasting = self.dataProvider.broadcasting
        broadcasting.$request.sink(receiveValue: { req in
            guard let requestPairing = req else { return }
            switch requestPairing{
            case .updateAllChannels :
                self.dataProvider.requestData(q: .init(type: .getAllChannels(self.pairing.getRegionCode())))
            case .updateCurrentBroadcast :
                self.dataProvider.requestData(q: .init(type: .getCurrentChannels(broadcasting.wepgVersion)))
            case .updateCurrentVod(let cid) :
                self.dataProvider.requestData(q: .init( id: self.tag,
                    type: .getSynopsis(SynopsisData(searchType: EuxpNetwork.SearchType.prd.rawValue, epsdRsluId: cid)))
                )
            }
        }).store(in: &anyCancellable)
    }
    
    func setupApiManager(_ apiManager:ApiManager){
        self.dataCancellable.forEach{$0.cancel()}
        self.dataCancellable.removeAll()
        apiManager.$result.sink(receiveValue: { res in
            guard let res = res else { return }
            switch res.type {
            case .getAllChannels :
                if let channels = res.data as? AllChannels {
                    self.dataProvider.broadcasting.updateAllChannels(channels)
                } else {
                    self.dataProvider.broadcasting.errorAllChannels()
                }
            case .getCurrentChannels :
                if let channels = res.data as? CurrentChannels {
                    self.dataProvider.broadcasting.updateCurrentBroadcast(channels)
                } else {
                    self.dataProvider.broadcasting.errorCurrentBroadcast()
                }
            case .getSynopsis :
                if res.id != self.tag { return }
                if let data = res.data as? Synopsis {
                    self.dataProvider.broadcasting.updateCurrentVod(synopsis: data)
                } else {
                    self.dataProvider.broadcasting.errorCurrentVod()
                }
            default: break
            }
        }).store(in: &dataCancellable)
        
        apiManager.$error.sink(receiveValue: { err in
            guard let err = err else { return }
            switch err.type {
            case .getAllChannels :
                self.dataProvider.broadcasting.errorAllChannels()
            case .getCurrentChannels :
                self.dataProvider.broadcasting.errorCurrentBroadcast()
            case .getSynopsis :
                if err.id != self.tag { return }
                self.dataProvider.broadcasting.errorCurrentVod()
            default: break
            }
        }).store(in: &dataCancellable)
    }
    
    
}
