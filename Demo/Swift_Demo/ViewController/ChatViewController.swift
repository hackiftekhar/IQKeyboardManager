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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.textFieldDidChange(_:)),    name: NSNotification.Name.UITextFieldTextDidChange, object: inputTextField)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: inputTextField)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return texts.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell", for: indexPath) as! ChatTableViewCell
        cell.chatLabel.text = texts[(indexPath as NSIndexPath).row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func sendAction(_ sender : UIButton) {
        if inputTextField.text?.characters.count != 0 {

            let indexPath = IndexPath(row: tableView.numberOfRows(inSection: 0), section: 0)
            
            texts.append(inputTextField.text!)
            inputTextField.text = ""
            buttonSend.isEnabled = false
            
            tableView.insertRows(at: [indexPath], with:UITableViewRowAnimation.automatic)
            tableView.scrollToRow(at: indexPath, at:UITableViewScrollPosition.none, animated:true)

        }
    }
    
    func textFieldDidChange(_ notification: Notification) {
        buttonSend.isEnabled = inputTextField.text?.characters.count != 0
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }
}
