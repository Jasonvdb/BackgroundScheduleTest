
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


//fileprivate func priceRequest(onSuccess: @escaping (Double) -> Void, onError: @escaping (String) -> Void) {
//    AF.request(apiUrl)
//    .validate()
//    .responseJSON { response in
//        switch response.result {
//        case .success(let value):
//            let data = JSON(value)
//
//            guard let price = data["ask"].double else {
//                onError("No price in data.")
//                return
//            }
//
//            onSuccess(price)
//
//        case .failure(let error):
//            onError(error.errorDescription ?? "API request failed.")
//        }
//    }
//}

//private func saveEntry(price: Double?, errorMessage: String = "Failed to fetch price") {
//    let newEntry = PriceEntry(context: context)
//    newEntry.created_at = Date()
//
//    UIDevice.current.isBatteryMonitoringEnabled = true
//
//    switch UIDevice.current.batteryState {
//    case .charging:
//        newEntry.power_status = "charging"
//        break
//    case .full:
//        newEntry.power_status = "full"
//        break
//    case .unplugged:
//        newEntry.power_status = "unplugged"
//        break
//    case .unknown:
//        newEntry.power_status = "unknown"
//    default:
//        newEntry.power_status = "-"
//    }
//
//    if let price = price {
//        newEntry.price = price
//        newEntry.note = "Price updated"
//    } else {
//        newEntry.note = errorMessage
//    }
//
//    do {
//        try context.save()
//    } catch {
//        print("Failed to save context: \(error)")
//    }
//
//    //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
//}

//func updatePrice() {
    
//}


class PriceUpdater: Operation {
    private let apiUrl = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTCUSD"
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var completionHandler: ((UIBackgroundFetchResult) -> Void)?
 
    init(_ completionHandler: ((UIBackgroundFetchResult) -> Void)? = nil) {
        super.init()
        
        self.completionHandler = completionHandler
    
        print("Op init")
    }
  
    override func main() {
        print("Op main*****")
        
        if isCancelled {
            return
        }

        self.priceRequest(onSuccess: { (price) in
            self.saveEntry(price: price)
            
            if let onComplete = self.completionHandler {
                onComplete(.newData)
            }
        }) { (errorMessage) in
            print(errorMessage)
            self.saveEntry(price: nil, errorMessage: errorMessage)
        }
    }
    
    private func saveEntry(price: Double?, errorMessage: String = "Failed to fetch price") {
        let newEntry = PriceEntry(context: context)
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
        
        if let price = price {
            newEntry.price = price
            newEntry.note = "Price updated"
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
    
    private func priceRequest(onSuccess: @escaping (Double) -> Void, onError: @escaping (String) -> Void) {
        AF.request(apiUrl)
        .validate()
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                let data = JSON(value)
                
                guard let price = data["ask"].double else {
                    onError("No price in data.")
                    return
                }
                
                onSuccess(price)

            case .failure(let error):
                onError(error.errorDescription ?? "API request failed.")
            }
        }
    }
}
