//
//  CountEntryTableViewController.swift
//  BackgroundScheduleTest
//
//  Created by Jason van den Berg on 2019/10/16.
//  Copyright © 2019 Jason van den Berg. All rights reserved.
//

import UIKit
import CoreData

class CountEntryTableViewController: UITableViewController {
    var countEntries: [CountEntry] = [CountEntry]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadCountEntries()
    }

    // MARK: - Table view data source
    func loadCountEntries(with request: NSFetchRequest<CountEntry> = CountEntry.fetchRequest()) {
        let sectionSortDescriptor = NSSortDescriptor(key: "created_at", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        request.sortDescriptors = sortDescriptors
        
        do {
            countEntries = try context.fetch(request)
        } catch {
            print("Failed to load entries \(error)")
        }
        
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countEntries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath)
        
        let countEntry: CountEntry = countEntries[indexPath.row]
        
        if countEntry.count == 0 {
            cell.textLabel?.text = "Failed ❌"
        } else {
            cell.textLabel?.text = "\(countEntry.count) ✅"
        }
        
        var timeLabelText = "-"
        if let createdAt = countEntry.created_at {
            if countEntries.indices.contains(indexPath.row + 1) {
                let previousCountEntries = countEntries[indexPath.row + 1]
                if let previousCreatedAt = previousCountEntries.created_at {
                    timeLabelText = "\(previousCreatedAt.timeAgoDisplay(compareDate: createdAt)) from previous"
                }
            }
        }
        
        cell.detailTextLabel?.text = timeLabelText
        
        let label = UILabel.init(frame: CGRect(x:0,y:0,width:30,height:20))
        
        switch countEntry.power_status {
            case "charging":
                label.text = "⚡"
                break
            case "full":
                label.text = "🔋"
                break
            case "unplugged":
                label.text = "🔌"
                break
            case "unknown":
                label.text = "❓"
            default:
                label.text = "❓❓"
        }
        
        cell.accessoryView = label
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let countEntry: CountEntry = countEntries[indexPath.row]
        let selectAlert = UIAlertController(title: "\(countEntry.created_at)", message: countEntry.note, preferredStyle: UIAlertController.Style.alert)

        selectAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in

        }))

        present(selectAlert, animated: true, completion: nil)
    }
    
    
    @IBAction func onDeleteAll(_ sender: Any) {
        let deleteAlert = UIAlertController(title: "Delete all", message: "All data entries will be lost.", preferredStyle: UIAlertController.Style.alert)

        deleteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.loadCountEntries()
            
            for countEntry in self.countEntries
            {
                self.context.delete(countEntry)
            }
            
            do {
                try self.context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
            
            self.loadCountEntries()
          }))

        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
          
          }))

        present(deleteAlert, animated: true, completion: nil)
    }
}
