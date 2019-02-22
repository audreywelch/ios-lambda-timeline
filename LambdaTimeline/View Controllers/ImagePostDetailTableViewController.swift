//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class ImagePostDetailTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    func updateViews() {
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else { return }
        
        title = post?.title
        
        imageView.image = image
        
        titleLabel.text = post.title
        authorLabel.text = post.author.displayName
    }
    
    // MARK: - Table view data source
    
    @IBAction func createComment(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Add a comment", message: "Create a text or audio comment", preferredStyle: .alert)
        
        // Text comment
        let textCommentAction = UIAlertAction(title: "Text Comment", style: .default) { (_) in
            
            let alert = UIAlertController(title: "Add a comment", message: "Write your comment below:", preferredStyle: .alert)
            
            var commentTextField: UITextField?
            
            alert.addTextField { (textField) in
                textField.placeholder = "Comment:"
                commentTextField = textField
            }
            
            let addCommentAction = UIAlertAction(title: "Add Comment", style: .default) { (_) in
                
                guard let commentText = commentTextField?.text else { return }
                
                self.postController.addComment(with: commentText, to: self.post!)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(addCommentAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)

            
        }
        
        // Audio comment
        let audioCommentAction = UIAlertAction(title: "Audio Comment", style: .default) { (_) in

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let recordViewController = storyboard.instantiateViewController(withIdentifier: "RecordViewController") as! RecordViewController
            
            recordViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            recordViewController.post = self.post
            self.present(recordViewController, animated: true, completion: nil)
            
            self.tableView.reloadData()
            
        }
        
        // Cancel action does nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addAction(textCommentAction)
        alertController.addAction(audioCommentAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.comments.count ?? 0) - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let comment = post?.comments[indexPath.row + 1]
        
        // If the audioURL is nil, the comment is a text comment
        if comment?.audioURL == nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
            
            cell.textLabel?.text = comment?.text
            cell.detailTextLabel?.text = comment?.author.displayName
            
            return cell
        } else {
            // if the audioURL is not nil, the comment is an audio comment
            let cell = tableView.dequeueReusableCell(withIdentifier: "audiocell", for: indexPath) as! AudioCell
            
            cell.timestampOutlet.text = "\(comment?.timestamp)"
            cell.nameOutlet.text = comment?.author.displayName
            
            return cell
        }
    }
    
    var post: Post!
    var postController: PostController!
    var imageData: Data?
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
}
