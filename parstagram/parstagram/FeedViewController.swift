//
//  FeedViewController.swift
//  parstagram
//
//  Created by Betsy Avila on 10/4/21.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar
//add uiviewcontroller delegate and data source
class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {

    @IBOutlet weak var tableview: UITableView!
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    var posts = [PFObject]() //array of PF Object
    var selectedPost: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        
        tableview.delegate = self
        tableview.dataSource = self
        
        tableview.keyboardDismissMode = .interactive //dismiss keyboard by dragging menu
        
        let center = NotificationCenter.default //broadcast notifications to hide keyboard
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWillBeHidden(note: Notification){
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    override var inputAccessoryView: UIView?{ //messageinputbar, hacking the framework
        return commentBar
    }
    override var canBecomeFirstResponder: Bool{//messageinputbar, hacking the framework
        return showsCommentBar //don't show by default
    }
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //create the comment
        //tie comments with text and post
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!
        
        selectedPost.add(comment, forKey: "comments")
        //want every post should have an array of comments, so add this comment to the array
        //different from firebase, parse saves the post and the comment automatically
        //we can see on the parse website the new comment column
        //the comment column only saves ID of the comment and not the object itself
        selectedPost.saveInBackground { (success, Error) in
            if success{
                print("Comment saved")
            }else{
                print("Error saving comment")
            }
        }
        
        tableview.reloadData() //refresh tables, reloadData() can do this with animations
        
        //clear and dismiss the input bar
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //make parse queries
        let query = PFQuery(className: "Posts")
        //options
        query.includeKeys(["author", "comments", "comments.author"]) //gets the pointer with the object inside of it
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
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? [] //optional operator, set to [] as default for nil values
        return comments.count + 2 //2 for the actual post and photo plus comment and add comment cell row
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //give each post a section like a 2d array
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as! PostTableViewCell
            
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
        }else if indexPath.row <= comments.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            let comment = comments[indexPath.row - 1] //if zero is post
            cell.commentLabel.text = (comment["text"] as? String)
            
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        }else{
            let cell = tableview.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
    
    }
  
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name:"Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene ,let delegate = windowScene.delegate as? SceneDelegate else{ return }//delegate gets UI type and typecasts it as SceneDelegate since window is in subclass
        delegate.window?.rootViewController = loginViewController
    }
    //create random comments
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject] ) ?? []   //uses Comments table
        
        //keyboard appears when clicked
        if indexPath.row == comments.count + 1{
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
        }
        
    }
    
}
