//
//  TextFieldSample.swift
//  SwiftMVVMBinding
//
//  Created by Darren Clark on 2015-11-19.
//  Copyright © 2015 theScore. All rights reserved.
//

import UIKit
import SwiftMVVMBinding

class TextFieldSampleViewModel {
    
    let firstName = Observable("")
    let lastName = Observable("")
    let email = Observable("")
    
    
    // Input valid?  (nil signifies no input/indeterminate)
    
    lazy var firstNameValid: Computed<Bool?> = Computed { [firstName = self.firstName] in
        firstName.value.isEmpty ? nil : true
    }
    
    lazy var lastNameValid: Computed<Bool?> = Computed { [lastName = self.lastName] in
        lastName.value.isEmpty ? nil : true
    }
    
    lazy var emailValid: Computed<Bool?> = Computed { [email = self.email] in
        if email.value.isEmpty {
            return nil
        }
        else {
            return email.value.rangeOfString("@") != nil
        }
    }
    
    
    lazy var inputValid: Computed<Bool> = Computed { [weak self] in
        self?.firstNameValid.value == true &&
            self?.lastNameValid.value == true &&
            self?.emailValid.value == true
    }
    
}


class TextFieldSampleViewController: UITableViewController {
    
    @IBOutlet var firstName: UITextField!
    @IBOutlet var lastName: UITextField!
    @IBOutlet var email: UITextField!
    
    @IBOutlet var firstNameValidity: UILabel!
    @IBOutlet var lastNameValidity: UILabel!
    @IBOutlet var emailValidity: UILabel!
    
    //MARK -
    
    let viewModel = TextFieldSampleViewModel()
    
    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstName.b_text <-> viewModel.firstName
        lastName.b_text <-> viewModel.lastName
        email.b_text <-> viewModel.email
        
        
        firstNameValidity.b_text.bind(viewModel.firstNameValid, transform: TextFieldSampleViewController.validStringTransform)
        firstNameValidity.b_textColor.bind(viewModel.firstNameValid, transform: TextFieldSampleViewController.validColorTransform)
        
        lastNameValidity.b_text.bind(viewModel.lastNameValid, transform: TextFieldSampleViewController.validStringTransform)
        lastNameValidity.b_textColor.bind(viewModel.lastNameValid, transform: TextFieldSampleViewController.validColorTransform)
        
        emailValidity.b_text.bind(viewModel.emailValid, transform: TextFieldSampleViewController.validStringTransform)
        emailValidity.b_textColor.bind(viewModel.emailValid, transform: TextFieldSampleViewController.validColorTransform)
        
        // Only let users move on to next field if they've correctly filled out the current one
        firstName.b_shouldReturn.bind(viewModel.firstNameValid, transform: { value in value ?? false })
        lastName.b_shouldReturn.bind(viewModel.lastNameValid, transform: { value in value ?? false })
        email.b_shouldReturn.bind(viewModel.emailValid, transform: { value in value ?? false })
        
        // Pressing enter should move the user on to the next field
        firstName.b_willReturn += { [weak self] in
            self?.lastName.becomeFirstResponder()
        }
        
        lastName.b_willReturn += { [weak self] in
            self?.email.becomeFirstResponder()
        }
        
        email.b_willReturn += { [weak self] in
            self?.email.resignFirstResponder()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        firstName.becomeFirstResponder()
    }
    
    //MARK: -
    
    static func validStringTransform(input: Bool?) -> String {
        switch input {
        case .None: return " "
        case .Some(true): return "✔︎"
        case .Some(false): return "✘"
        }
    }
    
    static func validColorTransform(input: Bool?) -> UIColor {
        switch input {
        case .None: return .blackColor()
        case .Some(true): return UIColor(red: 0.1, green: 0.8, blue: 0.15, alpha: 1.0)
        case .Some(false): return UIColor(red: 0.88, green: 0.0, blue: 0.0, alpha: 1.0)
        }
    }
}
