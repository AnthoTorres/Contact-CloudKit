//
//  ContactDetailViewController.swift
//  Contacts-CloudKit
//
//  Created by Anthony Torres on 12/13/19.
//  Copyright © 2019 Anthony Torres. All rights reserved.
//

import UIKit

class ContactDetailViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    var contact: Contact?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    func updateViews() {
        guard let contact = contact else { return }
        nameTextField.text = contact.name
        phoneNumberTextField.text = contact.phoneNumber
        addressTextField.text = contact.emailAddress
    }
    
    func dismissView() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let name = nameTextField.text, !name.isEmpty, let phoneNumber = phoneNumberTextField.text, let email = addressTextField.text
            else {return}
        if let contact = self.contact {
            contact.name = name
            contact.phoneNumber = phoneNumber
            contact.emailAddress = email
            ContactController.shared.updateContact(contact: contact) { (success) in
                if success {
                    self.dismissView()
                }
            }
        } else {
            ContactController.shared.createContact(name: name, phoneNumber: phoneNumber, emailAddress: email) { (success) in
                if success {
                    self.dismissView()
                }
            }
        }
        navigationController?.popViewController(animated: true)
    }
}
