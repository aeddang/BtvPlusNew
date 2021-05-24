import Foundation
import SwiftUI
import Combine

class Alram : ObservableObject, PageProtocol{
    
    @Published private(set) var newCount:Int = 0
    @Published private(set) var needUpdateNew:Bool = true
    @Published private(set) var isChangeNotification:Bool = false
    
    @discardableResult
    func updateNew() -> Int {
        if !self.needUpdateNew {return self.newCount}
        self.newCount = NotificationCoreData().getAllNotices().filter{!$0.isRead}.count
        self.needUpdateNew = false
        return self.newCount
    }
    func getHistorys() -> [NotificationEntity] {
        let historys = NotificationCoreData().getAllNotices()
        let new =  historys.filter{!$0.isRead}.count
        self.newCount = new
        self.isChangeNotification = false
        self.needUpdateNew = false
        return historys
    }
    func changedNotification(){
        self.isChangeNotification = true
    }
    func updatedNotification(){
        self.needUpdateNew = true
    }
}
