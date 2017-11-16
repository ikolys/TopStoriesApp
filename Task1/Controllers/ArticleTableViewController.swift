//
//  ArticleTableViewController.swift
//  Task1
//
//  Created by user132392 on 11/8/17.
//  Copyright © 2017 user132392. All rights reserved.
//

import UIKit
import CoreData

class ArticleTableViewController: UITableViewController {
    
    let articlesUpdater = ArticlesUpdater()
    var articlesForDate: [ArticlesForDate] = [] {
        didSet {
            self.tableView.reloadData()
            refreshControl?.endRefreshing()
        }
    }
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "New York Times Top Stories"
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Fetching NYT Top Stories...")
        refreshControl?.addTarget(self, action:#selector(refreshData), for: .valueChanged)
        refreshData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    @objc func refreshData() {
        articlesUpdater.fetchArticlesFromWebAndSave(inContext: container!.viewContext, completion: self.updateDidFinish)
    }
    
    func updateDidFinish() -> Void {
        articlesForDate = articlesUpdater.fetchAllArticlesFromDatabaseGrouppedByDate(inContext: container!.viewContext)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return articlesForDate.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return articlesForDate[section].articles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath)
        let row = indexPath.row
        let section = indexPath.section
        let article: Article = articlesForDate[section].articles[row]
        cell.textLabel?.text = article.title
        cell.detailTextLabel?.text = article.section
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return articlesForDate[section].date
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let id = segue.identifier
        if id == "showDetails" {
            if let cell = sender as? UITableViewCell {
                let row = tableView.indexPath(for: cell)?.row
                let section = tableView.indexPath(for: cell)?.section
                if let destination = segue.destination as? ArticleDetailsViewController, let articleSection=section, let articleRow=row {
                    let article: Article = articlesForDate[articleSection].articles[articleRow]
                    destination.articleURL = article.url
                }
            }
        }
    }
    

}
