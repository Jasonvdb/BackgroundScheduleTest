
//
//  Task.swift
//  BackgroundScheduleTest
//
//  Created by Jason van den Berg on 2019/10/16.
//  Copyright © 2019 Jason van den Berg. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class MempoolUpdater: Operation {
    private let apiUrl = "https://blockstream.info/api/blocks/tip/height"
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var completionHandler: ((UIBackgroundFetchResult) -> Void)?
 
    init(_ completionHandler: ((UIBackgroundFetchResult) -> Void)? = nil) {
        super.init()
        
        self.completionHandler = completionHandler
    }
  
    override func main() {
        if isCancelled {
            return
        }

        self.countRequest(onSuccess: { (count) in
            self.saveEntry(count: count)
            
            if let onComplete = self.completionHandler {
                onComplete(.newData)
            }
        }) { (errorMessage) in
            print(errorMessage)
            self.saveEntry(count: nil, errorMessage: errorMessage)
            if let onComplete = self.completionHandler {
                onComplete(.failed)
            }
        }
    }
    
    private func saveEntry(count: Int?, errorMessage: String = "Failed to fetch mempool count") {
        let newEntry = CountEntry(context: context)
        newEntry.created_at = Date()
        
        UIDevice.current.isBatteryMonitoringEnabled = true

        switch UIDevice.current.batteryState {
        case .charging:
            newEntry.power_status = "charging"
            break
        case .full:
            newEntry.power_status = "full"
            break
        case .unplugged:
            newEntry.power_status = "unplugged"
            break
        case .unknown:
            newEntry.power_status = "unknown"
        default:
            newEntry.power_status = "-"
        }
        
        if let count = count {
            newEntry.count = Int32(count)
            newEntry.note = "Count updated"
        } else {
            newEntry.note = errorMessage
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
        
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    private func countRequest(onSuccess: @escaping (Int) -> Void, onError: @escaping (String) -> Void) {
        let utilityQueue = DispatchQueue.global(qos: .background)

        AF.request(self.apiUrl)
        .validate()
            .responseJSON(queue: utilityQueue) { response in
            switch response.result {
            case .success(let value):
                let data = JSON(value)
                
                print(data)
                
                guard let count: Int = data.int else {
                    onError("No count in data.")
                    return
                }
                
                onSuccess(count)

            case .failure(let error):
                onError(error.errorDescription ?? "API request failed.")
            }
        }
        
    }
}
