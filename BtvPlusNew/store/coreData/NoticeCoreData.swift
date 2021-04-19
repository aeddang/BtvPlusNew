//
//  NoticeCoreData.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/04/19.
//

import Foundation
import CoreData

class NoticeCoreData:PageProtocol {
    static let name = "BtvPlus"
    static let model = "NotificationEntity"
    struct Keys {
        static let badge = "badge"
        static let title = "title"
        static let body = "body"
        static let body = "body"
        static let body = "body"
        static let body = "body"
    }
    
    func addKeyword(_ word:String){
        let container = self.persistentContainer
        guard let entity = NSEntityDescription.entity(forEntityName: Self.name, in: container.viewContext) else { return }
        let item = NSManagedObject(entity: entity, insertInto: container.viewContext)
        item.setValue(word, forKey: )
        self.saveContext()
    }

    func removeKeyword(_ word:String){
        let container = self.persistentContainer
        do {
            let fetchRequest:NSFetchRequest<Keyword> = Keyword.fetchRequest()
            fetchRequest.predicate = NSPredicate.init(format: "id = '\(word)'")
            let objects = try container.viewContext.fetch(fetchRequest)
            for obj in objects {
                container.viewContext.delete(obj)
            }
            self.saveContext()
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
        }
    }
    
    func getAllKeywords()->[String]{
        let container = self.persistentContainer
        do {
            let items = try container.viewContext.fetch(Keyword.fetchRequest()) as! [Keyword]
            return items.filter{$0.id != nil}.map{($0.id!)}
            
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
            return []
        }
    }
    
    
    // MARK: - Core Data stack
    private lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: Self.name)
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
