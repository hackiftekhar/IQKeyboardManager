//
//  ChatViewController.swift
//  Demo
//
//  Created by IEMacBook01 on 23/05/16.
//  Copyright © 2016 Iftekhar. All rights reserved.
//


class ChatViewController: UIViewController, UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate {

    @IBOutlet var tableView : UITableView!

    @IBOutlet var buttonSend : UIButton!
    @IBOutlet var inputTextField : UITextField!

    var texts = ["This is demo text chat. Enter your message and hit `Send` to add more chat."]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputTextField.inputAccessoryView = UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.textFieldDidChange(_:)),    name: UITextFieldTextDidChangeNotification, object: inputTextField)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: inputTextField)
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return texts.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatTableViewCell", forIndexPath: indexPath) as! ChatTableViewCell
        cell.chatLabel.text = texts[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    @IBAction func sendAction(sender : UIButton) {
        if inputTextField.text?.characters.count != 0 {

            let indexPath = NSIndexPath(forRow: tableView.numberOfRowsInSection(0), inSection: 0)
            
            texts.append(inputTextField.text!)
            inputTextField.text = ""
            buttonSend.enabled = false
            
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimation.Automatic)
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition:UITableViewScrollPosition.None, animated:true)

        }
    }
    
    func textFieldDidChange(notification: NSNotification) {
        buttonSend.enabled = inputTextField.text?.characters.count != 0
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {

    }
}
