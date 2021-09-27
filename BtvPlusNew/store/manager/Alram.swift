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
        self.updateBadge()
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
        self.updateBadge()
    }
    
    func updateBadge(){
        let num = NotificationCoreData().getAllNotices().filter{!$0.isRead}.count
        self.newCount = num
        self.needUpdateNew = false
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = num
        }
    }
}
