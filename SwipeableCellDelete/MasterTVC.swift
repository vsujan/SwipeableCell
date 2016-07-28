//
//  MasterTVC.swift
//  SwipeableCellDelete
//
//  Created by Sujan Vaidya on 7/21/16.
//  Copyright © 2016 lftechnology. All rights reserved.
//

import UIKit

class MasterTVC: UITableViewController {

    var strings: [String] = ["Cell 1", "Cell 2", "Cell 3", "Cell 4", "Cell 5"]
    var cellsCurrentlyEditing: NSMutableSet?
    
    var openCellIndex: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cellsCurrentlyEditing = NSMutableSet()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return strings.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(String(SwipeableCell), forIndexPath: indexPath) as? SwipeableCell
        guard let customCell = cell else { return UITableViewCell() }
        customCell.delegate = self
        customCell.myTextLabel.text = strings[indexPath.row]
        if self.cellsCurrentlyEditing!.containsObject(indexPath) {
            customCell.openCell()
        }
        return customCell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
}

extension MasterTVC: SwipeableCellDelegate {
    func button1ClickedForAction(sender: UIButton) {
        strings.removeAtIndex((openCellIndex?.row)!)
        let cellToDelete = tableView.cellForRowAtIndexPath(openCellIndex!) as? SwipeableCell
        cellToDelete!.closeCell()
        self.tableView.reloadData()
    }
    
    func button2ClickedForAction(sender: UIButton) {
        //
    }
    
    func cellDidOpen(cell: UITableViewCell) {
        if let indexPath = openCellIndex {
            let openCell = tableView.cellForRowAtIndexPath(indexPath) as? SwipeableCell
            openCell!.closeCell()
        }
        openCellIndex = self.tableView.indexPathForCell(cell)!
    }
    
    func cellDidClose(cell: UITableViewCell) {
        openCellIndex = nil
    }
}
