//
//  ViewController.swift
//  BackgroundScheduleTest
//
//  Created by Jason van den Berg on 2019/10/16.
//  Copyright © 2019 Jason van den Berg. All rights reserved.
//

import UIKit
import CoreData
import BackgroundTasks

class HomeViewController: UIViewController {
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!
    @IBOutlet weak var schduledTimeLabel: UILabel!
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //updatePrice()
        loadLatestPriceEntry()
        
//        let op = PriceUpdater()
//        op.start()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadLatestPriceEntry()
        
        BGTaskScheduler.shared.getPendingTaskRequests { (requests: [BGTaskRequest]) in
            for request in requests {
                //print("\(request.)")
                if let earliestBeginDate = request.earliestBeginDate {
                    DispatchQueue.main.async {
                      self.schduledTimeLabel.text = ("Scheduled to run \(earliestBeginDate.timeAgoDisplay())")
                    }
                }
            }
        }
    }
    
    private func loadLatestPriceEntry() {
        let request: NSFetchRequest<PriceEntry> = PriceEntry.fetchRequest()
        let sectionSortDescriptor = NSSortDescriptor(key: "created_at", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        request.sortDescriptors = sortDescriptors
        request.fetchLimit = 1;

        var entries: [PriceEntry] = [PriceEntry]()
        
        do {
            entries = try context.fetch(request)
        } catch {
            print("Error loading entries: \(error)")
            return
        }
        
        guard entries.count > 0 else {
            print("No data yet")
            return;
        }
        
        let latestEntry = entries[0]
        
        if latestEntry.price != 0 {
            priceLabel.text = "$ \(latestEntry.price)"
            updatedAtLabel.text = "Updated \(latestEntry.created_at!.timeAgoDisplay()) while \(latestEntry.power_status!)"
        } else {
            priceLabel.text = "$ ???"
            updatedAtLabel.text = "Last update failed:  \(latestEntry.note ?? "No reason.")"
        }
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let calendar = Calendar.current
        let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date())!
        let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date())!
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!

        if minuteAgo < self {
            let diff = Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
            return "\(diff) sec ago"
        } else if hourAgo < self {
            let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
            return "\(diff) min ago"
        } else if dayAgo < self {
            let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
            return "\(diff) hrs ago"
        } else if weekAgo < self {
            let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
            return "\(diff) days ago"
        }
        let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
        return "\(diff) weeks ago"
    }
}
