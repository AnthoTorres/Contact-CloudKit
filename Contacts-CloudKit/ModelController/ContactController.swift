//
//  ContactController.swift
//  Contacts-CloudKit
//
//  Created by Anthony Torres on 12/13/19.
//  Copyright © 2019 Anthony Torres. All rights reserved.
//

import Foundation
import CloudKit

class ContactController {
    
    static let shared = ContactController()
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    var contacts:[Contact] = []
    
    func createContact(name: String, phoneNumber: String?, emailAddress: String?, completion: @escaping (_ success: Bool) -> Void) {
        
        let contact = Contact(name: name, phoneNumber: phoneNumber, emailAddress: emailAddress)
        
        guard let record = contact.record else {
            print("Could not convert contact to ckrecord")
            return
        }
        publicDB.save(record) { (savedRecord, error) in
            if let error = error {
                print("There was an error saving the CKRecord of contact \(error)")
            }
            guard let record = savedRecord else {
                print("No record to return")
                completion(false)
                return
            }
            guard let savedContact = Contact(ckRecord: record) else {
                print("Unable to convert CKRecord to Contact")
                completion(false)
                return
            }
            self.contacts.append(savedContact)
            print("Saved Contact Success")
            completion(true)
        }
    }
    
    func fetchAllContact(completion: @escaping (_ success:Bool) -> Void) {
        
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: Constant.contactRecordTypeKey, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
                return
            }
            guard let records = records else { completion(false); return }
            let contacts = records.compactMap({ Contact(ckRecord: $0)})
            self.contacts = contacts
            completion(true)
        }
    }
    
    func updateContact(contact: Contact, completion: @escaping (Bool) -> Void) {
        
        let record = CKRecord(contact: contact)
        
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        
        operation.queuePriority = .veryHigh
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (records, _, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
                return
            }
            guard record == records?.first else { completion(false); return }
            print("Updated \(record.recordID.recordName)")
            completion(true)
        }
        publicDB.add(operation)
        
    }
    
    func deleteContact(contact: Contact, completion: @escaping (_ success: Bool) -> Void) {
        
        let modificationOP = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [contact.ckRecordID])
        
        modificationOP.qualityOfService = .userInteractive
        modificationOP.queuePriority = .veryHigh
        modificationOP.modifyRecordsCompletionBlock = { _, recordIDs, error in
            if let error = error {
                print("There was an error with the modificationOP completion \(error)")
                completion(false)
                return
            }
            guard contact.ckRecordID == recordIDs?.first else { completion(false); return}
            print("successfully deleted Contact")
            completion(true)
        }
        publicDB.add(modificationOP)
    }
}
