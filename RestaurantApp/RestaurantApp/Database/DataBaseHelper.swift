//
//  DataBaseHelper.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 11/14/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DataBaseHelper{
    
    static let shared = DataBaseHelper()
    
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    func saveData(token : String){
        let user = NSEntityDescription.insertNewObject(forEntityName: "UserData", into: context!) as! UserData
        user.tokenId = token
        do{
            try context?.save()
        }catch{
            print("An error occured")
        }
    }
    
    func getData() -> [UserData]{
        var user = [UserData]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserData")
        do{
            user = try context?.fetch(fetchRequest) as! [UserData]
        }catch{
            print("cannot fetch data")
        }
        debugPrint((user.first?.tokenId) ?? "")
        return user
    }
    
    func emptyCoreData(){
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "UserData")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do{
            let _ = try context?.execute(request)
        }catch{
            print("cannot be deleted")
        }
    }
}
