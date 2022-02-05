//
//  ContactsHelper.swift
//  D3Contacts
//
//  Created by Branden Smith on 10/14/19.
//

import Contacts
import ContactsUI
import Foundation
import RxSwift
import RxCocoa

/// Contacts Helper Mode enumeration
public enum ContactsHelperMode {
    /// Zelle: Import Contact regular mode that requires a promise Id and a web bridge call from the web: `getZelleContact`
    case zelle
    /// Fiserv SSO: Add contact from device mode that responds to FTK url schemes.
    case fiserv
}

public struct ContactResult {
    public let json: [String: Any]?
    public let promiseId: String?
    public let mode: ContactsHelperMode
}

public class DeviceContact: Codable {
    var name: String = ""
    var tokens: [String] = []
}

public final class ContactsHelper: NSObject {
    public let selectedContactProperty: PublishRelay<ContactResult> = PublishRelay<ContactResult>()
    
    private var currentPromiseId: String?
    private var currentMode: ContactsHelperMode = .zelle
    private weak var viewController: UIViewController?
    public let contactStore = CNContactStore()
    
    public func chooseContact(
        fromViewController viewController: UIViewController,
        withPromiseId promiseId: String?,
        mode: ContactsHelperMode) {
        self.viewController = viewController
        self.currentPromiseId = promiseId
        self.currentMode = mode
        
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.displayedPropertyKeys = [
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey
        ]
        
        viewController.present(contactPicker, animated: true, completion: nil)
    }
}

extension ContactsHelper: CNContactPickerDelegate {
    public func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        guard contactProperty.key == CNContactPhoneNumbersKey || contactProperty.key == CNContactEmailAddressesKey else {
            fatalError("Expected either a phone number or email address. Received: \(contactProperty.key)")
        }
        
        let properties = getContactPropertiesDictionary(contactProperty, for: currentMode)
        selectedContactProperty.accept(ContactResult(json: properties, promiseId: currentPromiseId, mode: currentMode))
        viewController = nil
        currentPromiseId = nil
    }
    
    public func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        selectedContactProperty.accept(ContactResult(json: nil, promiseId: currentPromiseId, mode: currentMode))
        viewController = nil
        currentPromiseId = nil
    }
}

extension ContactsHelper {
    private func getContactPropertiesDictionary(_ contactProperty: CNContactProperty, for mode: ContactsHelperMode) -> [String: Any] {
        var properties: [String: Any] = [:]
        switch mode {
        case .zelle:
            properties["name"] = CNContactFormatter().string(from: contactProperty.contact)
            if let phoneNumber = contactProperty.value as? CNPhoneNumber {
                properties["token"] = phoneNumber.stringValue
            } else {
                properties["token"] = contactProperty.value as! String
            }
            
        case .fiserv:
            if let phoneNumber = contactProperty.value as? CNPhoneNumber {
                properties["tokenValue"] = phoneNumber.stringValue
            } else {
                properties["tokenValue"] = contactProperty.value as! String
            }
            
            properties["firstName"] = contactProperty.contact.givenName
            properties["lastName"] = contactProperty.contact.familyName
            
            if (contactProperty.key == CNContactPhoneNumbersKey) {
                properties["tokenType"] = "phone"
            } else if (contactProperty.key == CNContactEmailAddressesKey) {
                properties["tokenType"] = "email"
            }
        }
        return properties
    }
    
    public func getDeviceContacts(contactsCompletionHandler: @escaping(Permission, [DeviceContact]) -> Void) {
        
        var deviceContacts = [DeviceContact]()
        
        let keys = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey
        ] as [Any]
        
        self.requestContactsAccess(completionHandler: { (permission) in
            switch permission {
            case .granted, .notDetermined:
                let  request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
                do {
                    
                    try self.contactStore.enumerateContacts(with: request, usingBlock: { (contact, _) in
                        let c = DeviceContact()
                        c.name = (contact.givenName + " " + contact.familyName).trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        for phoneNumber in contact.phoneNumbers {
                            if let number = phoneNumber.value as? CNPhoneNumber {
                                c.tokens.append(number.stringValue)
                            }
                        }
                        
                        for email in contact.emailAddresses {
                            if let emailAddress = email.value as? NSString {
                                c.tokens.append(emailAddress as String)
                            }
                        }
                        
                        deviceContacts.append(c)
                    })
                    
                    contactsCompletionHandler(permission, deviceContacts)
                } catch let error {
                    fatalError("Failed to enumerate contact: \(error)")
                }
                
            case .denied:
                contactsCompletionHandler(permission, deviceContacts)
            }
        })
    }
    
    public func requestContactsAccess(completionHandler: @escaping(Permission) -> Void) {
        self.contactStore.requestAccess(for: .contacts, completionHandler: { (granted, _) in
            if granted {
                completionHandler(.granted)
            } else {
                completionHandler(.denied)
            }
        })
    }
    
    public func contactsAuthorizationStatus() -> String {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        switch status {
        case .authorized:
            return Permission.granted.rawValue
        case .denied, .restricted:
            return Permission.denied.rawValue
        case .notDetermined:
            return Permission.notDetermined.rawValue
        @unknown default:
            fatalError("Unknown permission value retruned.")
        }
    }
    
    public enum Permission: String {
        case granted
        case denied
        case notDetermined
    }
}
