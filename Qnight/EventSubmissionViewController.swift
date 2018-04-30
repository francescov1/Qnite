//
//  EventSubmissionViewController.swift
//  Qnight
//
//  Created by Francesco Virga on 2017-08-13.
//  Copyright © 2017 David Choi. All rights reserved.
//
import UIKit

class EventSubmissionViewController: UIViewController {
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.setValue(UIColor.white, forKey: "textColor")
        
        
        // gesture to remove textfield when view is tapped
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EventSubmissionViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    
}
extension EventSubmissionViewController: UITextFieldDelegate {
    
    
    
    // close keyboard when return key tapped
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
            return true
        }
        // Do not add a line break
        return false
        
    }
    
    // function fired
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
