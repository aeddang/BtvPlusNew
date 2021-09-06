//
//  NoticeCoreData.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/04/19.
//

import Foundation
import CoreData

class KeywordCoreData:PageProtocol {
    static let model = "KeywordEntity"
    struct Keys {
        static let itemId = "id"
    }
    
    func addKeyword(_ word:String){
        
        let container = self.persistentContainer
        guard let entity = NSEntityDescription.entity(forEntityName: Self.model, in: container.viewContext) else { return }
        let item = NSManagedObject(entity: entity, insertInto: container.viewContext)
        item.setValue(word, forKey: Keys.itemId)
        //self.saveContext()
    }

    func removeKeyword(_ word:String){
        
        do {
            let container = self.persistentContainer
            let fetchRequest:NSFetchRequest<KeywordEntity> = KeywordEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate.init(format: "id = '\(word)'")
            let objects = try container.viewContext.fetch(fetchRequest)
            for obj in objects {
                container.viewContext.delete(obj)
            }
            //self.saveContext()
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
        }
    }
    
    func getAllKeywords()->[String]{
        
        do {
            let request = NSFetchRequest<KeywordEntity>(entityName: KeywordCoreData.model)
            let container = self.persistentContainer
            let items = try container.viewContext.fetch(request) as [KeywordEntity]
            if items.isEmpty { return [] }
            return items.filter{$0.id != nil}.map{($0.id!)}
            
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
    func saveContext () {
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


