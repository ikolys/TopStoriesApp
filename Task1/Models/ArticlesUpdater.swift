//
//  ArticlesUpdater.swift
//  Task1
//
//  Created by user132392 on 11/8/17.
//  Copyright © 2017 user132392. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ArticlesUpdater {
    
    let topStoriesURL = "https://api.nytimes.com/svc/topstories/v2/home.json"
    let apiKey = "a699c7ec6336482e83c7e5800d6e2265"
    var delegate : ArticlesUpdaterDelegate?
    
    func fetchArticlesFromWebAndSave(inContext context: NSManagedObjectContext) {
        let url = URL(string: topStoriesURL)
        var request: URLRequest = URLRequest(url: url!)
        request.setValue(apiKey, forHTTPHeaderField: "api-key")
        let dataTask = URLSession.shared.dataTask(with: request) {
            [unowned self] (data,response,error) in
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    if let results = jsonResult["results"] as? [[String: Any]] {
                        DispatchQueue.main.async {
                            for item in results {
                                if let url = item["url"] as? String {
                                    guard self.fetchArticleFromDatabase(withUrl: url, inContext: context) == nil else  { continue }
                                    let article = Article.init(entity: NSEntityDescription.entity(forEntityName: "Article", in:context)!, insertInto: context)
                                    article.title = item["title"] as? String
                                    article.abstract = item["abstract"] as? String
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                                    let date = dateFormatter.date(from: (item["published_date"] as? String)!)!
                                    article.published_date = date
                                    article.url = item["url"] as? String
                                    article.section = item["section"] as? String
                                    if let multimedia = item["multimedia"] as? [[String: Any]] {
                                        if multimedia.count > 0 {
                                            let index = multimedia.index(where: {$0["format"] as! String == "superJumbo"})
                                            if let i = index {
                                                article.image_url = multimedia[i]["url"] as? String
                                            }
                                            
                                        }
                                    }
                                    do {
                                        try context.save()
                                    } catch let error as NSError {
                                        print(error.localizedDescription)
                                    }
                                }
                            }
                            self.delegate?.updateDidFinish()
                        }
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
        dataTask.resume()
    }
    
    func fetchAllArticlesFromDatabase(inContext context: NSManagedObjectContext) -> [Article] {
        let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Article.published_date), ascending: false)
        fetchRequest.sortDescriptors = [sort]
        
        var result = [Article]()
        
        do {
            // Execute Fetch Request
            result = try context.fetch(fetchRequest)
            
        } catch {
            print("Unable to fetch managed objects for entity Article.")
        }
        
        return result
    }
    
    func fetchAllArticlesFromDatabaseGrouppedByDate(inContext context:NSManagedObjectContext) -> [ArticlesForDate]{
        var resultsByDate = [ArticlesForDate]()
        let records: [Article] = fetchAllArticlesFromDatabase(inContext: context)
       
        if records.count > 0 {
            for article in records {
                let articleDateTimeString: String = (article.published_date?.description)!
                let articleDate = String(articleDateTimeString[..<articleDateTimeString.index(articleDateTimeString.startIndex, offsetBy: 10)])
                if let index = resultsByDate.index(where: { $0.date == articleDate}) {
                    resultsByDate[index].articles.append(article)
                } else {
                    let articlesForDate = ArticlesForDate()
                    articlesForDate.date = articleDate
                    articlesForDate.articles = [article]
                    resultsByDate.append(articlesForDate)
                }
            }
            resultsByDate = resultsByDate.sorted { $0.date > $1.date }
        }
        return resultsByDate
    }
    
    func fetchArticleFromDatabase(withUrl url: String, inContext context: NSManagedObjectContext) -> Article? {
        let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "url == %@", url)
        
        var result: Article?
        
        do {
            // Execute Fetch Request
            let record = try context.fetch(fetchRequest)
            if record.count > 0 {
                result = record[0]
            }
        } catch {
            print("Unable to fetch managed objects for entity Article.")
        }
        
        return result
    }
    
    func fetchImage(from url: String) {
        //creating a dataTask
        let URL_IMAGE = URL(string: url)
        let getImageFromUrl = URLSession(configuration: .default).dataTask(with: URL_IMAGE!) { [unowned self] (data, response, error) in
            
            //if there is any error
            if let e = error {
                //displaying the message
                print("Error Occurred: \(e)")
                
            } else {
                //in case of no error, checking whether the response is nil or not
                if (response as? HTTPURLResponse) != nil {
                    if let imageData = data {
                        DispatchQueue.main.async {
                            self.delegate?.imageFetched(data: imageData)
                        }
                    } else {
                        print("Image file is currupted")
                    }
                } else {
                    print("No response from server")
                }
            }
        }
        
        //starting the download task
        getImageFromUrl.resume()
    }
    
}

protocol ArticlesUpdaterDelegate {
    func updateDidFinish()
    func imageFetched(data: Data)
}

extension ArticlesUpdaterDelegate {
    func updateDidFinish() {
        
    }
    func imageFetched(data: Data) {
        
    }
}
