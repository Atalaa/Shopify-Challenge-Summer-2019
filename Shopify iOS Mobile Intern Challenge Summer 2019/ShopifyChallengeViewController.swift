//
//  ViewController.swift
//  Shopify iOS Mobile Intern Challenge 2019
//
//  Created by atala rchidi on 2019-01-12.
//  Copyright © 2019 Atala Rchidi. All rights reserved.
//

import UIKit

class ShopifyChallengeViewController: UITableViewController {

    var myRow : String = ""
    var myIndexPath : Int = 0
    var itemArray = ["Aerodynamic", "Awesome", "Durable", "Enormous", "Ergonomic", "Fantastic", "Gorgeous", "Heavy Duty", "Incredible", "Intelligent", "Lightweight", "Mediocre", "Practical", "Rustic", "Sleek", "Small", "Synergistic"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemArray.sort()
    }
    
    //How many rows we want in our table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    /* Is triggered when tableview looks to find something to display in the tableview. Here we provide cells that will be displayed indexPath is the current indexpath that the tableview is looking to fill. It's a location identifier for each of these cell */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagsItemCell", for: indexPath)
        
        //label are in every single cell, here we set it to its text property. The current text that is displayed by the label
        cell.textLabel?.text = itemArray[indexPath.row]
        
        return cell
    }
    
    //TableView Delegate Method get fired whenever we click/select on any cell in the tableview
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        myRow = itemArray[indexPath.row]
        myIndexPath = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        
        //trigger the segway, self because this class initiated the segue
        self.performSegue(withIdentifier: "goToProducts", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToProducts" {
            let x = segue.destination as! ProductsTableViewController
            x.myRowProduct = myRow
        }
    }
}
