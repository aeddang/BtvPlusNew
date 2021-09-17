//
//  CoreData.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/16.
//

import Foundation
import CoreData

class ApiCoreDataManager:PageProtocol {
    static let name = "BtvPlus"
    
    struct Models {
        static let item = "Item"
    }
    struct Keys {
        static let itemId = "id"
        static let itemJson = "jsonString"
    }
    
    /*
    func clearData(server:ApiServer) {
        switch server {
        case .VMS:do{}
        default: do{}
        }
    }*/

    func setData<T:Encodable>(key:String, data:T?){
        guard let data = data else { return }
        let jsonData = try! JSONEncoder().encode(data)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        let container = self.persistentContainer
        guard let entity = NSEntityDescription.entity(forEntityName: Models.item, in: container.viewContext) else { return }
        let item = NSManagedObject(entity: entity, insertInto: container.viewContext)
        item.setValue(key, forKey: Keys.itemId)
        item.setValue(jsonString, forKey: Keys.itemJson)
        self.saveContext()
    }
    
    func getData<T:Decodable>(key:String)->T?{
        let container = self.persistentContainer
        do {
            let items = try container.viewContext.fetch(Item.fetchRequest()) as! [Item]
            guard let jsonString = items.first(where: {$0.id == key})?.jsonString else { return nil }
            let jsonData = jsonString.data(using: .utf8)!
            do {
                let savedData = try JSONDecoder().decode(T.self, from: jsonData)
                return savedData
            } catch {
                DataLog.e(error.localizedDescription, tag: self.tag)
                return nil
            }
        } catch {
           DataLog.e(error.localizedDescription, tag: self.tag)
           return nil
        }
    }

    
    // MARK: - Core Data stack
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = BtvPlusPersistentContainer(name: Self.name)
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
