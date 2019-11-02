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
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!
    @IBOutlet weak var schduledTimeLabel: UILabel!
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadLatestCountEntry()
        
//        let op = MempoolUpdater()
//        op.start()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadLatestCountEntry()
        
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
    
    private func loadLatestCountEntry() {
        let request: NSFetchRequest<CountEntry> = CountEntry.fetchRequest()
        let sectionSortDescriptor = NSSortDescriptor(key: "created_at", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        request.sortDescriptors = sortDescriptors
        request.fetchLimit = 1;

        var entries: [CountEntry] = [CountEntry]()
        
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
        
        if latestEntry.count != 0 {
            countLabel.text = "\(latestEntry.count)"
            updatedAtLabel.text = "Updated \(latestEntry.created_at!.timeAgoDisplay()) ago while \(latestEntry.power_status!)"
        } else {
            countLabel.text = "$ ???"
            updatedAtLabel.text = "Last update failed:  \(latestEntry.note ?? "No reason.")"
        }
    }
}

extension Date {
    func timeAgoDisplay(compareDate: Date = Date()) -> String {
        let calendar = Calendar.current
        let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: compareDate)!
        let hourAgo = calendar.date(byAdding: .hour, value: -1, to: compareDate)!
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: compareDate)!
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: compareDate)!

        if minuteAgo < self {
            let diff = Calendar.current.dateComponents([.second], from: self, to: compareDate).second ?? 0
            return "\(diff) seconds"
        } else if hourAgo < self {
            let diff = Calendar.current.dateComponents([.minute], from: self, to: compareDate).minute ?? 0
            return "\(diff) minutes"
        } else if dayAgo < self {
            let diff = Calendar.current.dateComponents([.hour], from: self, to: compareDate).hour ?? 0
            return "\(diff) hours"
        } else if weekAgo < self {
            let diff = Calendar.current.dateComponents([.day], from: self, to: compareDate).day ?? 0
            return "\(diff) days"
        }
        let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: compareDate).weekOfYear ?? 0
        return "\(diff) weeks"
    }
}
