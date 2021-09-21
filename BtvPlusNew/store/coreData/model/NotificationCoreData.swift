//
//  NoticeCoreData.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/04/19.
//

import Foundation
import CoreData


class NotificationCoreData:PageProtocol { 
    static let model = "NotificationEntity"
    struct Keys {
        static let badge = "badge"
        static let title = "title"
        static let body = "body"
        static let date = "date"
        static let userInfo = "userInfo"
        static let isRead = "isRead"
    }
    
    func addNotice(_ userInfo: [AnyHashable: Any]){
        var badge:Int = 0
        var title:String = ""
        var body:String = ""
        if let aps = userInfo["aps"] as? [String: Any] {
            if let value = aps["badge"] as? Int { badge = value }
            if let alert = aps["alert"] as? [String: Any] {
                if let value = alert["title"] as? String { title = value }
                if let value = alert["body"] as? String { body = value }
            } else {
                if let value = aps["alert"] as? String { body = value }
            }
        }
        
        let container = self.persistentContainer
        container.performBackgroundTask { context in
            guard let entity = NSEntityDescription.entity(forEntityName: Self.model, in: container.viewContext) else { return }
            let item = NSManagedObject(entity: entity, insertInto: container.viewContext)
            item.setValue(title, forKey: Self.Keys.title)
            item.setValue(badge, forKey: Self.Keys.badge)
            item.setValue(body, forKey: Self.Keys.body)
            item.setValue(Date(), forKey: Self.Keys.date)
            item.setValue(false, forKey: Self.Keys.isRead)
            item.setValue(userInfo, forKey: Self.Keys.userInfo)
            self.saveContext()
        }
    }

    func removeNotice(_ noti:NotificationEntity){
        self.persistentContainer.viewContext.delete(noti)
        self.saveContext()
    }
    
    func removeAllNotice(){
        self.getAllNotices().forEach{
            self.persistentContainer.viewContext.delete($0)
        }
        self.saveContext()
    }
    
    func readAllNotice(){
        let container = self.persistentContainer
        do {
            let fetchRequest:NSFetchRequest<NotificationEntity> = NotificationEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate.init(format: "isRead == 'false'")
            let objects = try container.viewContext.fetch(fetchRequest)
            for obj in objects {
                obj.setValue(true, forKey: Self.Keys.isRead)
            }
            self.saveContext()
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
        }
    }
    
    func readNotice(title:String, body:String){
        let container = self.persistentContainer
        do {
            let fetchRequest:NSFetchRequest<NotificationEntity> = NotificationEntity.fetchRequest()
            let predicateTitle = NSPredicate(format: "title == '" + title + "'")
            let predicateBody = NSPredicate(format: "body == '" + body + "'")
            let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicateTitle,predicateBody])
            fetchRequest.predicate = predicateCompound
            let objects = try container.viewContext.fetch(fetchRequest)
            for obj in objects {
                obj.setValue(true, forKey: Self.Keys.isRead)
            }
            self.saveContext()
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
        }
    }
    
    func getAllNotices()->[NotificationEntity]{
        let container = self.persistentContainer
        do {
            let items = try container.viewContext.fetch(NotificationEntity.fetchRequest())
            let now:Double = Date().timeIntervalSince1970 - (15 * 24 * 60 * 60)
            var notices:[NotificationEntity] = []
            items.forEach{
                if $0.date?.timeIntervalSince1970 ?? 0 > now {
                    notices.append($0)
                } else {
                    removeNotice($0)
                }
            }
            return notices.sorted(by: {($0.date?.timeIntervalSince1970 ?? 0) > ($1.date?.timeIntervalSince1970 ?? 0)})
            
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
            return []
        }
    }
    
    
    // MARK: - Core Data stack
    private lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: ApiCoreDataManager.name)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    private func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}


//{
//   "aps":{
//      "alert":{
//         "title":"시놉 바로가기",
//         "body":"push 메시지입니다."
//      },
//      "mutable-content":1
//   },
//    "system_data":{
//      "messageId":"pixunptufh3uncbogyadn",
//      "ackUrl":"",
//      "blob":null,
//      "hasMore":false,
//      "type":"message"
//   },
//   "user_data":{
//      "msgType":"content",
//      "sysType":"Admin",
//      "imgType":"icon",
//      "landingPath":"SYNOP",
//      "posterUrl":"PIMG",
//      "title":"시놉 바로가기",
//      "iconUrl":"IIMG",
//      "receiveLimit":"",
//      "destPos":"http:\\/\\/m.btvplus.co.kr?type=30&id=CE0001166079",
//      "timestamp":"20201111180000",
//      "notiType":"ALL"
//   }
//}
