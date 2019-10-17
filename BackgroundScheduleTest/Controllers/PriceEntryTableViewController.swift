//
//  PriceEntryTableViewController.swift
//  BackgroundScheduleTest
//
//  Created by Jason van den Berg on 2019/10/16.
//  Copyright © 2019 Jason van den Berg. All rights reserved.
//

import UIKit
import CoreData

class PriceEntryTableViewController: UITableViewController {
    var priceEntries: [PriceEntry] = [PriceEntry]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        loadPriceEntries()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadPriceEntries()
    }
    

    // MARK: - Table view data source
    func loadPriceEntries(with request: NSFetchRequest<PriceEntry> = PriceEntry.fetchRequest()) {
        let sectionSortDescriptor = NSSortDescriptor(key: "created_at", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        request.sortDescriptors = sortDescriptors
        
        do {
            priceEntries = try context.fetch(request)
        } catch {
            print("Failed to load entries \(error)")
        }
        
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return priceEntries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath)
        
        let priceEntry: PriceEntry = priceEntries[indexPath.row]
        
        if priceEntry.price == 0 {
            cell.textLabel?.text = "Failed ❌"
        } else {
            cell.textLabel?.text = "$ \(priceEntry.price)"
        }
        cell.detailTextLabel?.text = priceEntry.created_at?.timeAgoDisplay()
        
        let label = UILabel.init(frame: CGRect(x:0,y:0,width:30,height:20))
        
        switch priceEntry.power_status {
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
    }
    
    
    @IBAction func onDeleteAll(_ sender: Any) {
        let deleteAlert = UIAlertController(title: "Delete all", message: "All data entries will be lost.", preferredStyle: UIAlertController.Style.alert)

        deleteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.loadPriceEntries()
            
            for priceEntry in self.priceEntries
            {
                self.context.delete(priceEntry)
            }
            
            do {
                try self.context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
            
            self.loadPriceEntries()
          }))

        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
          
          }))

        present(deleteAlert, animated: true, completion: nil)
    }
}
