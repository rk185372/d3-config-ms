//
//  OOBSetUpVerificationViewController.swift
//  OutOfBand
//
//  Created by Padmanabhuni Bhaskaruni, Nagasri Sai Swetha on 12/30/20.
//

import CompanyAttributes
import Foundation
import ComponentKit
import PostAuthFlowController
import UIKit
import UITableViewPresentation
import Session
import RxSwift
import Utilities
import Logging
import UserInteraction
import Network

public final class OOBSetUpVerificationViewController: UIViewControllerComponent {
    
    @IBOutlet weak var logoImageView: UIImageViewComponent!
    @IBOutlet weak var tableview: UITableViewComponent!
    
    private let oobService: OOBService
    weak var controller: PostAuthFlowController?
    private let companyAttributes: CompanyAttributesHolder
    private var dataSource: UITableViewPresentableDataSource!
    private let userSession: UserSession
    private let currentOobUserProfile: UserProfile
    private var addtionalEmailLabelText = ""
    private var addtionalPhoneNumLabelText = ""
    private let userInteraction: UserInteraction
    private var selectedEmails: [String] = []
    private var selectedMobileNumbers: [String] = []
    private var emailAddressArray: [String] = []
    private var phoneNumbersArray: [String] = []
    private var isEmailErrorOnScreen: Bool = false
    private var isPhoneErrorOnScreen: Bool = false
    private var isAddtionalEmailTextSelected: Bool = false
    private var addtionalEmailText = ""
    private var isAddtionalPhoneNumTextSelected: Bool = false
    private var addtionalPhoneNumText = ""
    private var availablePhoneType = ""
    private var availableEmailType = ""
    private var additionalEmailSectionNumber = 0
    private var additionalPhoneNumSectionNumber = 0
    
    init(config: ComponentConfig,
         oobService: OOBService,
         postAuthFlowController: PostAuthFlowController?,
         companyAttributesHolder: CompanyAttributesHolder,
         userSession: UserSession,
         userInteraction: UserInteraction) {
        
        self.oobService = oobService
        self.controller = postAuthFlowController
        self.userSession = userSession
        self.userInteraction = userInteraction
        self.companyAttributes = companyAttributesHolder
        self.currentOobUserProfile = self.userSession.userProfiles.first { $0.profileType == "CONSUMER" }!
        
        super.init(
            l10nProvider: config.l10nProvider,
            componentStyleProvider: config.componentStyleProvider,
            nibName: String(describing: type(of: self)),
            bundle: OutOfBandBundle.bundle
        )
        
        self.addtionalEmailLabelText = l10nProvider.localize("credentials.oob-reset.add.email")
        self.addtionalPhoneNumLabelText = l10nProvider.localize("credentials.oob-reset.add.phone")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        logoImageView.image = UIImage(named: "FullLogo")
    }
}

// MARK: - Private
private extension OOBSetUpVerificationViewController {
    func setUpTableView() {
        tableview.separatorStyle = .none
        dataSource = UITableViewPresentableDataSource(tableView: tableview)
        dataSource.tableViewModel = createTableViewModel()
        dataSource.delegate = self
        tableview.allowsSelection = false
    }
    
    func createTableViewModel() -> UITableViewModel {
        
        let footerButtons = FooterButtonsPresentable(cancelText: l10nProvider.localize("credentials.oob-reset.button.cancel")
            , continueText: l10nProvider.localize("credentials.oob-reset.button.continue"), delegate: self)
        
        emailAddressArray = getEmailAddressFrom(userProfile: currentOobUserProfile)
        let emailAddressesRows = emailAddressArray.map {
            return EmailAddressPresentable(email: $0, delegate: self)
        }
        
        phoneNumbersArray = getPhoneNumbersFrom(userProfile: currentOobUserProfile)
        let phoneNumbersRow = phoneNumbersArray.map {
            return PhoneNumPresentable(phoneNum: $0, delegate: self)
        }
        
        let newSelectionEmailPresentable = NewSelectionPresentable(
            placeholder: l10nProvider.localize("credentials.oob-reset.add.email.hint"),
            infoText: "",
            invalidErrorText: self.l10nProvider.localize("credentials.oob-reset.error.invalid.email"),
            itemListedErrorText: self.l10nProvider.localize("credentials.oob-reset.error.already.listed"),
            isEmailCell: true,
            delegate: self)
        
        let newSelectionPhonePresentable = NewSelectionPresentable(
            placeholder: l10nProvider.localize("credentials.oob-reset.add.phone.hint"),
            infoText: l10nProvider.localize("credentials.oob-reset.add.textmessagescharge"),
            invalidErrorText: self.l10nProvider.localize("credentials.oob-reset.error.invalid.phone"),
            itemListedErrorText: self.l10nProvider.localize("credentials.oob-reset.error.already.listed"),
            isEmailCell: false,
            delegate: self)
        
        var sections: [UITableViewSection] = [
            UITableViewSection(
                rows: [AnyUITableViewPresentable(SetUpInfoPresentable())],
                header: .presentable(AnyUITableViewHeaderFooterPresentable(
                    HeaderTitlesPresentable(title: l10nProvider.localize("credentials.oob-reset.setup.title"), subtitle: "")))
            )
        ]
        sections.append(UITableViewSection(
            rows: emailAddressesRows,
            header: .presentable(AnyUITableViewHeaderFooterPresentable(
                HeaderTitlesPresentable(title: l10nProvider.localize("credentials.oob-reset.contact.title"),
                                        subtitle: l10nProvider.localize("credentials.oob-reset.contact.ratio")))))
        )
        // Only append if a new Email type is available in user profile
        if (self.availableEmailType != "") {
            sections.append(UITableViewSection(rows: [newSelectionEmailPresentable]))
            self.additionalEmailSectionNumber = sections.count - 1
        }
        
        sections.append(UITableViewSection(rows: phoneNumbersRow))
        // Only append if a new Phone type is available in user profile
        if (self.availablePhoneType != "") {
            sections.append(UITableViewSection(rows: [newSelectionPhonePresentable]))
            self.additionalPhoneNumSectionNumber = sections.count - 1
        }
        
        sections.append(UITableViewSection(rows: [footerButtons]))
        return UITableViewModel(sections: sections)
    }
    
    private func showFailedToSendRequestError(withError: String) {
        let alert = UIAlertController(
            title: l10nProvider.localize("app.error.generic.title"),
            message: withError,
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(title: l10nProvider.localize("app.alert.btn.ok"), style: .default) { _ in
                self.dismiss(animated: true, completion: nil)
            }
        )
        
        present(alert, animated: true, completion: nil)
    }
    
    private func handleResponseError(_ error: Error) {
        switch error {
        case ResponseError.failureWithMessage(let message), ResponseError.unauthenticated(let message):
            self.showFailedToSendRequestError(withError: message)
        default:
            self.showFailedToSendRequestError(withError: l10nProvider.localize("app.error.generic"))
        }
    }
}

// MARK: - UITableViewPresentableDataSourceDelegate
extension OOBSetUpVerificationViewController: UITableViewPresentableDataSourceDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, presentable: AnyUITableViewPresentable) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// Submit or Cancel Button Delegates
extension OOBSetUpVerificationViewController: FooterButtonsDelegate {
    
    func cancelButtonTouched(_ sender: UIButtonComponent) {
        userInteraction.triggerUserInteraction()
        NotificationCenter.default.post(name: .loggedOut, object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    func continueButtonTouched(_ sender: UIButtonComponent) {
        if(isEmailErrorOnScreen || isPhoneErrorOnScreen) {
            self.showFailedToSendRequestError(withError: l10nProvider.localize("credentials.oob-reset.error.formInvalid"))
            return
        }
        
        if self.isAddtionalEmailTextSelected {
            if (self.addtionalEmailText != "") {
                self.addEmailAndPhoneNumbersToSelectedList(selectedValue: self.addtionalEmailText, isEmail: true)
            } else {
                self.showFailedToSendRequestError(withError: l10nProvider.localize("credentials.oob-reset.error.formInvalid"))
                return
            }
        }
        
        if self.isAddtionalPhoneNumTextSelected {
            if (self.addtionalPhoneNumText != "") {
                self.addEmailAndPhoneNumbersToSelectedList(selectedValue: self.addtionalPhoneNumText, isEmail: false)
            } else {
                self.showFailedToSendRequestError(withError: l10nProvider.localize("credentials.oob-reset.error.formInvalid"))
                return
            }
        }
        
        if(selectedEmails.isEmpty && selectedMobileNumbers.isEmpty) {
            self.showFailedToSendRequestError(withError: l10nProvider.localize("credentials.oob-reset.error.nothing.selected"))
            return
        }
        beginLoading(fromButton: sender)
        // Get the Updated UserProfile object
        let userProfile = self.getUpdatedUserProfile()
            
        // Call the service method.
        oobService.putOutOfBandDestinations(userProfile: userProfile)
            .subscribe({ [unowned self] (result) in
                switch result {
                case .success:
                    self.controller?.advance()
                case .error(let error):
                    log.error("Error setting Out of Band \(error)", context: error)
                    self.handleResponseError(error)
                    self.cancelables.cancel()
                }
            })
            .disposed(by: cancelables)
    }
}

// Checkbox Button Delegate
extension OOBSetUpVerificationViewController: EmailCheckboxButtonDelegate {
    /// Adds emails from the list that are already in the user profile
    /// Not the additional email texts and phone numbers
    func emailCheckboxTouched(checkbox: UICheckboxComponent, selectedCell: EmailAddressCell?) {
        guard  let selectedValue = selectedCell?.emailAdressLabel?.text else {
            return
        }
        // Only add if the value is not Additional Email text
        if(selectedValue != "" && selectedValue != addtionalEmailLabelText) {
            // If the value is already in list then remove it
            // else add it to list
            self.addEmailAndPhoneNumbersToSelectedList(selectedValue: selectedValue, isEmail: true)
        } else if (selectedValue == addtionalEmailLabelText) {
            let indexPath = IndexPath.init(row: 0, section: self.additionalEmailSectionNumber)
            let newselectedCell = self.tableview.cellForRow(at: indexPath) as! NewSelectionCell
            if (selectedCell?.emailCheckbox.checkState == .unchecked) {
                newselectedCell.textfield.text = ""
                newselectedCell.errorLabel.text = ""
                isEmailErrorOnScreen = false
                isAddtionalEmailTextSelected = false
            } else if (selectedCell?.emailCheckbox.checkState == .checked) {
                isAddtionalEmailTextSelected = true
            }
        }
    }
}

extension OOBSetUpVerificationViewController: MobileCheckboxButtonDelegate {
    /// Adds phone numbers from the list that are already in the user profile
    /// Not the additional email texts and phone numbers
    func mobileCheckboxTouched(checkbox: UICheckboxComponent, selectedCell: PhoneNumCell?) {
        guard let selectedValue = selectedCell?.mobileNumLabel?.text else {
            return
        }
        
        // Only add if the value is not Additional Mobile number text
        if(selectedValue != "" && selectedValue != self.addtionalPhoneNumLabelText) {
            // If the value is already in list then remove it
            // else add it to list
            self.addEmailAndPhoneNumbersToSelectedList(selectedValue: selectedValue, isEmail: false)
        } else if (selectedValue == self.addtionalPhoneNumLabelText) {
            let indexPath = IndexPath.init(row: 0, section: self.additionalPhoneNumSectionNumber)
            let newselectedCell = self.tableview.cellForRow(at: indexPath) as! NewSelectionCell
            if (selectedCell?.mobileCheckbox.checkState == .unchecked) {
                newselectedCell.textfield.text = ""
                newselectedCell.errorLabel.text = ""
                isPhoneErrorOnScreen = false
                isAddtionalPhoneNumTextSelected = false
            } else if (selectedCell?.mobileCheckbox.checkState == .checked) {
                isAddtionalPhoneNumTextSelected = true
            }
        }
    }
}

// Delegate Methods
extension OOBSetUpVerificationViewController: NewSelectionPresentableDelegate {
    func setErrorField(value: Bool, isEmail: Bool) {
        if(isEmail) {
            self.isEmailErrorOnScreen = value
        } else {
            self.isPhoneErrorOnScreen = value
        }
    }
    
    func keyboardClearButtonTouched(_ sender: UIBarButtonItem, currentCellText: String, isEmail: Bool) {
        // Remove the existing once if user already entered and try to clear the text field
        if(isEmail) {
            isEmailErrorOnScreen = false
            selectedEmails.removeAll { $0 == currentCellText }
        } else {
            isPhoneErrorOnScreen = false
            selectedMobileNumbers.removeAll { $0 == currentCellText }
        }
    }
    
    // Checks if Email And Phone numbers exists in Array
    // Returns false if already exists else true
    func checkIfEmailPhoneNumberExistsInUserProfile(currentCellText: String, isEmail: Bool) -> Bool {
        if(isEmail) {
            if(self.checkIfEmailExistsInUserProfile(newEmail: currentCellText)) {
                self.isEmailErrorOnScreen = true
            } else {
                if (currentCellText == "" || currentCellText.isValidEmail()) {
                    self.addtionalEmailText = currentCellText
                    self.isEmailErrorOnScreen = false
                    return true
                }
            }
        } else {
            if(self.checkIfPhoneNumExistsInUserProfile(newPhoneNumber: currentCellText)) {
                self.isPhoneErrorOnScreen = true
            } else {
                if (currentCellText == "" || currentCellText.isValidPhone()) {
                    self.addtionalPhoneNumText = currentCellText
                    self.isPhoneErrorOnScreen = false
                    return true
                }
            }
        }
        return false
    }
}

// Private methods
extension OOBSetUpVerificationViewController {
    /// Gets Email Address from User profile to display on the page.
    private func getEmailAddressFrom(userProfile: UserProfile) -> [String] {
        var emailAddressArray: [String] = []
        let emailAddresses = userProfile.emailAddresses
        let maxEmailNumber = getContactEmailLimit()
        
        // For Primary users, get all the email addresses listed.
        if (userProfile.type == "PRIMARY") {
            for item in 0..<emailAddresses.count {
                emailAddressArray.append(emailAddresses[item].value)
            }
        } else {
            // For secondary users, get the primary email address
            // If not exists get the first email address available
            let emailContact = emailAddresses.first { $0.primary == true }?.value ?? emailAddresses.first?.value ?? ""
            if(emailContact != "") {
                emailAddressArray.append(emailContact)
            }
        }
        
        // For secondary users we dont enable the email input option
        if (userProfile.type == "PRIMARY") {
            if (maxEmailNumber == 0 || userProfile.emailAddresses.count < maxEmailNumber) {
                for item in 0..<userProfile.validEmailTypes.count {
                    // Check if the email address types are not present in the user profile with the valid email types
                    // Or check if the email type is repeatable, then capture the available email type to be added for text input.
                    if (userProfile.emailAddresses.first { $0.subType != nil &&
                        $0.subType == userProfile.validEmailTypes[item].internalName } == nil ||
                        userProfile.validEmailTypes[item].repeatable == true) {
                        self.availableEmailType = userProfile.validEmailTypes[item].internalName
                        break
                    }
                }
                
                // If email address type is not empty, means that we have a valid input email type that can be added
                if (self.availableEmailType != "") {
                    emailAddressArray.append(self.addtionalEmailLabelText)
                }
            }
        }
        
        return emailAddressArray
    }
    
    /// Gets Phone Numbers from User profile to display on the page.
    private func getPhoneNumbersFrom(userProfile: UserProfile) -> [String] {
        var phoneNumbersArray: [String] = []
        let phoneNumbers = userProfile.phoneNumbers
        let maxPhonesNumber = getContactPhonesLimit()
        
        for item in 0..<phoneNumbers.count {
            if (phoneNumbers[item].sms == true
                && phoneNumbers[item].subType != nil
                && phoneNumbers[item].subType == "MOBILE") {
                phoneNumbersArray.append(phoneNumbers[item].value)
            }
        }
        
         if (userProfile.type == "PRIMARY") {
            if (maxPhonesNumber == 0 || userProfile.phoneNumbers.count < maxPhonesNumber) {
                let validType = userProfile.validPhoneTypes.first { $0.internalName == "MOBILE" }
                // if valid type is repeatable then only add additional phone numbers
                if (userProfile.phoneNumbers.first { $0.subType == validType?.internalName } == nil ||
                    validType?.repeatable == true) {
                    availablePhoneType = validType?.internalName ?? ""
                }
                
                if (availablePhoneType == "MOBILE") {
                    phoneNumbersArray.append(self.addtionalPhoneNumLabelText)
                }
            }
         } else {
            // For secondary users if phone numbers list is empty, then show for additional phones
            // else dont show the additional phone number item
            if (phoneNumbersArray.isEmpty) {
                self.availablePhoneType = "MOBILE"
                phoneNumbersArray.append(self.addtionalPhoneNumLabelText)
            }
        }
        
        return phoneNumbersArray
    }
    
    func getContactEmailLimit() -> Int {
        return self.companyAttributes.companyAttributes.value?.intValue(forKey: "settings.profile.emailAddress.limit") ?? 0
    }
    
    func getContactPhonesLimit() -> Int {
        return self.companyAttributes.companyAttributes.value?.intValue(forKey: "settings.profile.phoneNumber.limit") ?? 0
    }
    
    /// Check and Add to selected list of email address and phone numbers to process the information later
    private func addEmailAndPhoneNumbersToSelectedList(selectedValue: String, isEmail: Bool) {
        // Remove from Selected Emails if isEmail is true
        if(isEmail) {
            selectedEmails.contains(selectedValue) ? selectedEmails.removeAll { $0 == selectedValue } : selectedEmails.append(selectedValue)
        } else {
            selectedMobileNumbers.contains(selectedValue) ? selectedMobileNumbers.removeAll {
                $0 == selectedValue } : selectedMobileNumbers.append(selectedValue)
        }
    }
    
    private func checkIfPhoneNumExistsInUserProfile(newPhoneNumber: String) -> Bool {
        return phoneNumbersArray.contains(newPhoneNumber)
    }
    
    private func checkIfEmailExistsInUserProfile(newEmail: String) -> Bool {
        return emailAddressArray.contains(newEmail)
    }
    
    /// Gets Updated User Profile for OOB Reset.
    private func getUpdatedUserProfile() -> UserProfile {
        let jsonDecoder = JSONDecoder()
        var userProfile = currentOobUserProfile
        
        for emailItem in 0..<selectedEmails.count {
            
            let currentItemIndex = userProfile.emailAddresses.firstIndex { $0.value == selectedEmails[emailItem] } ?? -1
            
            // If item exists set outof band to true, else add new email address
            if(currentItemIndex >= 0) {
                userProfile.emailAddresses[currentItemIndex].outOfBand = true
            } else {
                if (self.availableEmailType != "") {
                    let destinationEmail = fillDestionationObjectWith(
                        value: selectedEmails[emailItem],
                        isMobile: false)
                    
                    let emailAddress = try! jsonDecoder.decode(Destination.self, from: destinationEmail)
                    userProfile.emailAddresses.append(emailAddress)
                }
            }
        }
        
        for phoneNumItem in 0..<selectedMobileNumbers.count {
            let currentItemIndex = userProfile.phoneNumbers.firstIndex { $0.value == selectedMobileNumbers[phoneNumItem] } ?? -1
            
            // If item exists set outof band to true, else add new phone number
            if(currentItemIndex >= 0) {
                userProfile.phoneNumbers[currentItemIndex].outOfBand = true
            } else {
                if (self.availablePhoneType != "") {
                    let destinationMobileNumber = fillDestionationObjectWith(
                        value: selectedMobileNumbers[phoneNumItem],
                        isMobile: true)
                    
                    let newMobileNumber = try! jsonDecoder.decode(Destination.self, from: destinationMobileNumber)
                    userProfile.phoneNumbers.append(newMobileNumber)
                }
            }
        }
        
        return userProfile
    }
    
    /// Fills the Destination Object to add to User profile
    private func fillDestionationObjectWith(value: String, isMobile: Bool) -> Data {
        let jsonEncoder = JSONEncoder()
        
        var encodedDestination = Data()
        
        if(isMobile) {
            // New Mobile Num Object
            let phoneNum = Destination(
                id: nil,
                type: "PHONE",
                label: "MOBILE",
                value: value,
                primary: false,
                outOfBand: true,
                readOnly: false,
                verified: false,
                alternate: nil,
                subType: "MOBILE",
                sms: true)
            
            encodedDestination = try! jsonEncoder.encode(phoneNum)
        } else {
            // New Email Address Object
            let email = Destination(
                id: nil,
                type: "EMAIL",
                label: self.availableEmailType,
                value: value,
                primary: self.availableEmailType == "PRIMARY",
                outOfBand: true,
                readOnly: false,
                verified: false,
                alternate: self.availableEmailType != "PRIMARY",
                subType: self.availableEmailType,
                sms: false)
            
            encodedDestination = try! jsonEncoder.encode(email)
        }
        
        return encodedDestination
    }
}
