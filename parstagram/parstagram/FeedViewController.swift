//
//  FeedViewController.swift
//  parstagram
//
//  Created by Betsy Avila on 10/4/21.
//

import UIKit
import Parse
import AlamofireImage
//add uiviewcontroller delegate and data source
class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    
    var posts = [PFObject]() //array of PF Object
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //make parse queries
        let query = PFQuery(className: "Posts")
        //options
        query.includeKey("author") //gets the pointer with the object inside of it
        query.limit = 20 //get last 20
        
        //tell tableview to get queries again
        query.findObjectsInBackground { (posts, error) in
            if posts != nil{
                self.posts = posts!
                self.tableview.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as! PostTableViewCell
        
        let post = posts[indexPath.row]
        print(post)
        //like a dictionary, unpack everything
        let user = post["author"] as! PFUser
        cell.userNameLabel.text = user.username
        cell.captionLabel.text = (post["caption"] as! String)
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        
        //use alamofireimage to take in url
        cell.photoView.af.setImage(withURL: url)
       
        return cell
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
