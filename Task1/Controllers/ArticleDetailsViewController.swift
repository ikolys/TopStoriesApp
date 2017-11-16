//
//  ArticleDetailsViewController.swift
//  Task1
//
//  Created by user132392 on 11/8/17.
//  Copyright © 2017 user132392. All rights reserved.
//
import CoreData
import UIKit

class ArticleDetailsViewController: UIViewController, ArticlesUpdaterDelegate {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var abstractLabel: UILabel!
    @IBOutlet weak var link: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var articleURL: String?
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    let articleUpdater = ArticlesUpdater()
    var article : Article? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        let dateString: String? = article?.published_date?.description
        dateLabel.text = String(dateString![..<dateString!.index(dateString!.startIndex, offsetBy: 19)])
        titleLabel.text = article?.title
        abstractLabel.text = article?.abstract
        //Fetch image
        if let image_url = article?.image_url {
            articleUpdater.fetchImage(from: image_url)
        } else {
            spinner.stopAnimating()
            imageView.image = UIImage(named: "if_camera")
        }
    }
    
    func imageFetched(data: Data) {
        spinner.stopAnimating()
        imageView.image = UIImage(data: data)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        articleUpdater.delegate = self
        spinner.startAnimating()
        article = articleUpdater.fetchArticleFromDatabase(withUrl: articleURL!, inContext: container!.viewContext)!
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let id = segue.identifier
        if id == "readMore" {
            if let destination = segue.destination as? WebViewController{
                    destination.url = articleURL
            }
        }
    }

}
