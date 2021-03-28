//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Rudransh Singh on 3/19/21.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar
class FeedViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,MessageInputBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    var posts = [PFObject]()
    var selectedPost : PFObject!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        commentBar.inputTextView.placeholder = "Add a comment"
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyBoardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        //tableView.rowHeight = 475
        // Do any additional setup after loading the view.
    }
    
    @objc func keyBoardWillBeHidden(note: Notification){
        commentBar.inputTextView.text = nil
        showsCommentBar=false
        becomeFirstResponder()
        
    }
    override var inputAccessoryView: UIView?{
        return commentBar
    }
    override var canBecomeFirstResponder: Bool{
        return showsCommentBar
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className: "Posts")
        query.includeKeys(["author","comments","comments.author"])
        query.limit = 20
        query.findObjectsInBackground{
            (posts,error) in
            if posts != nil{
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
               let comment = PFObject(className: "Comments")
               comment["text"] = text
               comment["post"] = selectedPost
               comment["author"] = PFUser.current()!
               selectedPost.add(comment, forKey: "comments")
               selectedPost.saveInBackground{
                   (success,error) in
                   if success{
                       print("Comment Saved")
                   }else{
                       print("Error saving the comment")
                   }
               }
        tableView.reloadData()
        commentBar.inputTextView.text = nil
        showsCommentBar=false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post=posts[section]
        let comment = (post["comments"] as? [PFObject]) ?? []
        return comment.count+2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comment = (post["comments"] as? [PFObject]) ?? []
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        if indexPath.row == 0{
            
       
        let user = post["author"] as! PFUser
        cell.usernameLabel.text = user.username
        cell.captionLabel.text = post["caption"] as! String
        let imagefile = post["image"] as! PFFileObject
        let urlstring = imagefile.url!
        let url = URL(string: urlstring)!
        cell.photoView.af_setImage(withURL: url)
        return cell
        }else if indexPath.row <= comment.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            let comment = comment[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as! String
            let user = comment["author"] as! PFUser
            cell.nameLabel.text=user.username
            
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
    }
    
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(identifier: "LoginViewController")
        let delegate = UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
        delegate.window?.rootViewController = loginViewController
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comment = (post["comments"] as? [PFObject]) ?? []
        if indexPath.row == comment.count + 1{
            showsCommentBar=true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            selectedPost = post
        }
        
        
//
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
