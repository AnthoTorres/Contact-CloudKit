//
//  ContactListTableViewController.swift
//  Contacts-CloudKit
//
//  Created by Anthony Torres on 12/13/19.
//  Copyright © 2019 Anthony Torres. All rights reserved.
//

import UIKit

class ContactListTableViewController: UITableViewController {
    
    var refreshControlUI = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadData()
        fetchContacts()
    }
    
    func fetchContacts() {
        
        ContactController.shared.fetchAllContact { (success) in
            if success {
            } else {
                print("No contacts to fetch")
            }
        }
    }
    
    func setupViews() {
        
        refreshControlUI.attributedTitle = NSAttributedString(string: "Pull to refresh contacts")
        refreshControlUI.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.tableView.addSubview(refreshControlUI)
    }
    
    func updateViews() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControlUI.endRefreshing()
        }
    }
    
    @objc private func loadData() {
        ContactController.shared.fetchAllContact { (success) in
            if success {
                self.updateViews()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ContactController.shared.contacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
        let contact = ContactController.shared.contacts[indexPath.row]
        cell.textLabel?.text = contact.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let contact = ContactController.shared.contacts[indexPath.row]
            guard let index = ContactController.shared.contacts.firstIndex(of: contact) else { return }
            ContactController.shared.deleteContact(contact: contact) { (success) in
                if success {
                    ContactController.shared.contacts.remove(at: index)
                    DispatchQueue.main.async {
                        tableView.deleteRows(at: [indexPath], with: .middle)
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ContactDetailViewController" {
            if let index = tableView.indexPathForSelectedRow {
                guard let destinationVC = segue.destination as? ContactDetailViewController else {return}
                let contactDataTransfered = ContactController.shared.contacts[index.item]
                destinationVC.contact = contactDataTransfered
            }
        }
    }
}
