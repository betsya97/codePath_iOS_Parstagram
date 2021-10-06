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
  
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name:"Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        let delegate =  UIApplication.shared.delegate as! SceneDelegate//delegate gets UI type and typecasts it as SceneDelegate since window is in subclass
        delegate.window?.rootViewController = loginViewController
    }
    //create random comments
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comment = PFObject(className: "Comments") //uses Comments table
        //tie comments with text and post
        comment["text"] = "this is a random comment"
        comment["post"] = post
        comment["author"] = PFUser.current()!
        
        post.add(comment, forKey: "comments")
        //want every post should have an array of comments, so add this comment to the array
        //different from firebase, parse saves the post and the comment automatically
        //we can see on the parse website the new comment column
        //the comment column only saves ID of the comment and not the object itself
        post.saveInBackground { (success, Error) in
            if success{
                print("Comment saved")
            }else{
                print("Error saving comment")
            }
        }
    }
    
}
