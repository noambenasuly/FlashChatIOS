//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    // Reference to database
    let db = Firestore.firestore()
    
    // Arry for messages from struct Message
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For data source from self tableview
        tableView.dataSource = self
        
        // Title on navigation bar ( From Constants )
        title = K.appName
        
        // Cancel back buttom navigation
        navigationItem.hidesBackButton = true
        
        // Register nib custom designed
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        loadMessages()

    }
    
    func loadMessages() {
        messages = []
        
        // Retrieving data messages from database(sender and body) real time listener and order by date
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener { querySnapshot, error in
                
            self.messages = []
                
            if let e = error {
                print("There was an issue retrieving data from Firestore. \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let messageSender = data[K.FStore.senderField] as? String , let messageBody = data[K.FStore.bodyField] as? String {
                            let newMessage = Message(sender: messageSender, body: messageBody)
                            self.messages.append(newMessage)
                            
                            // Reload the data from database to our tableview
                            DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                
                                // Option to scroll message on tableView
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        // Body message come from user to database
        if let messageBody = messageTextfield.text ,
        // Who is the user that sent the message
           let messageSender = Auth.auth().currentUser?.email{
            db.collection(K.FStore.collectionName).addDocument(data: [
                K.FStore.senderField: messageSender,
                K.FStore.bodyField: messageBody,
                K.FStore.dateField: Date().timeIntervalSince1970
            ]) { (error) in
                if let e = error {
                    print("There was an issue saving data , \(e)")
                } else {
                    print("Successfuly saved data. " )
                    
                    // Clean text field after send message
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""

                    }
                }
            }
        }
    }

    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        do {
          try Auth.auth().signOut()
           
            // Navigation to welcomeViewController
            navigationController?.popToRootViewController(animated: true)
            
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
}

// Request data when tableview load up
extension ChatViewController: UITableViewDataSource {
    
    // Num of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    // Data from cell sender me and another sender
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)
        as! MessageCell
        cell.lable.text = message.body
        
        // This is a message from currnt user
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.lable.textColor = UIColor(named: K.BrandColors.purple)
            
        } else {
            
            // This message from another sender
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.lable.textColor = UIColor(named: K.BrandColors.lightPurple)
            
        }
        
        return cell
    }
}
