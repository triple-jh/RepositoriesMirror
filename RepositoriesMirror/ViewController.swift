//
//  ViewController.swift
//  RepositoriesMirror
//
//  Created by JJaeyang on 2017/11/22.
//  Copyright © 2017年 JJaeyang. All rights reserved.
//

import UIKit
import AFNetworking
import SwiftyJSON
import SDWebImage

class ViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    var JSONData: [JSON] = Array()
    var lastSince = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // SearchBar
        searchBar.setValue("cancel", forKey: "_cancelButtonText")
        
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData()
    {
        self.view.addSubview(Loading.shared)
        Loading.shared.start()
        
        let parameter: [String: AnyObject] = ["since": "\(lastSince)" as AnyObject]
        let manager = AFHTTPSessionManager()
        manager.get("https://api.github.com/repositories", parameters: parameter, progress: nil,
                    success:
            {
                (operation, json) in
                
                // 예외처리.
                let data = JSON(json ?? JSON())
                for (_, value):(String, JSON) in data
                {
                    self.JSONData.append(value)
                }
                
                // since = last id
                if let last = self.JSONData.last
                {
                    self.lastSince = last["id"].intValue
                }
                    
                self.tableView.reloadData()
                Loading.shared.stop()
        }, failure:
            {
                (operation, error) in
                Loading.shared.stop()
        })
    }
}

// MARK: UITableView
extension ViewController: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return JSONData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "repocell", for: indexPath) as! tableCell
        cell.set(data: JSONData[indexPath.row])
    
        return cell
    }
}

class tableCell: UITableViewCell
{
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var ownerName: UILabel!
    
    func set(data: JSON)
    {
        // name
        if let name = data["name"].string//data["owner"]["avatar_url"].string
        {
            ownerName.text = name
        }
        // avatar image
        guard let link = data["owner"]["avatar_url"].string else { return }
        
        let manager = SDWebImageManager.shared()
        let key = manager.cacheKey(for: URL(string: link))
        let thumbnailImage =
            manager.imageCache?.imageFromMemoryCache(forKey: key) ??
                manager.imageCache?.imageFromDiskCache(forKey: key) ??
                UIImage()
        
        avatarImage.sd_setImage(with: URL(string: link), placeholderImage: thumbnailImage, options: .scaleDownLargeImages, completed: nil)

    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
    }
}

// MARK: ScrollView
extension ViewController: UIScrollViewDelegate
{
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        debugPrint("endDragging")
        if ((tableView.contentOffset.y + tableView.frame.size.height) >= tableView.contentSize.height)
        {
            loadData()
        }
    }
}

extension ViewController: UISearchBarDelegate
{
    // 검색 버튼이 눌렸을 때.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        searchBar.showsCancelButton = false//true
    }
    
    // 취소 버튼이 눌렸을 때.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        self.view.endEditing(true)
        searchBar.text = ""
    }
    
    // 텍스트필드 입력개시할 때.
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(ViewController.reload), object: nil)
        self.perform(#selector(ViewController.reload), with: nil, afterDelay: 0.5)
    }
    
    @objc func reload()
    {
        if let text = searchBar.text
        {
            debugPrint("reload search \(text)")
        }
    }
    
    func debounce(interval: Int, queue: DispatchQueue, action: @escaping (() -> Void)) -> () -> Void {
        var lastFireTime = DispatchTime.now()
        let dispatchDelay = DispatchTimeInterval.milliseconds(interval)
        
        return {
            lastFireTime = DispatchTime.now()
            let dispatchTime: DispatchTime = DispatchTime.now() + dispatchDelay
            
            queue.asyncAfter(deadline: dispatchTime) {
                let when: DispatchTime = lastFireTime + dispatchDelay
                let now = DispatchTime.now()
                if now.rawValue >= when.rawValue {
                    action()
                }
            }
        }
    }
}
