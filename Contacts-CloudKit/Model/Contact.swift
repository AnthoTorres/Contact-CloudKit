//
//  Contact.swift
//  Contacts-CloudKit
//
//  Created by Anthony Torres on 12/13/19.
//  Copyright © 2019 Anthony Torres. All rights reserved.
//

import Foundation
import CloudKit

class Contact {
   
    var name: String
    var phoneNumber: String?
    var emailAddress: String?
    let ckRecordID: CKRecord.ID
    
    var record: CKRecord? {
        let record = CKRecord(recordType: Constant.contactRecordTypeKey, recordID: ckRecordID)
        record.setValue(name, forKey: Constant.nameKey)
        if let phoneNumber = phoneNumber {
            record.setValue(phoneNumber, forKey: Constant.phoneNumberKey)
        }
        if let emailAddress = emailAddress {
            record.setValue(emailAddress, forKey: Constant.emailAddressKey)
        }
        return record
    }
    init(name:String, phoneNumber: String?, emailAddress: String?, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.emailAddress = emailAddress
        self.ckRecordID = recordID
    }
}

extension CKRecord {
    convenience init(contact: Contact) {
        self.init(recordType: Constant.contactRecordTypeKey, recordID: contact.ckRecordID)
        self.setValue(contact.name, forKey: Constant.nameKey)
        self.setValue(contact.phoneNumber, forKey: Constant.phoneNumberKey)
        self.setValue(contact.emailAddress, forKey: Constant.emailAddressKey)
    }
}

extension Contact {
    convenience init?(ckRecord: CKRecord) {
        guard let name = ckRecord[Constant.nameKey] as? String,
            let phoneNumber = ckRecord[Constant.phoneNumberKey] as? String?,
            let emailAddress = ckRecord[Constant.emailAddressKey] as? String?
            else { return nil }
        self.init(name: name, phoneNumber: phoneNumber, emailAddress: emailAddress, recordID: ckRecord.recordID)
    }
}

extension Contact: Equatable {
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        return lhs.ckRecordID == rhs.ckRecordID
    }
}

struct Constant {
    static let contactRecordTypeKey = "Contact"
    static let nameKey = "name"
    static let phoneNumberKey = "phoneNumber"
    static let emailAddressKey = "emailAddress"
}
