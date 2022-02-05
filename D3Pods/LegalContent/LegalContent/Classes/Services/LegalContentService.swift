//
//  LegalContentService.swift
//  LegalContent
//
//  Created by Chris Carranza on 5/22/18.
//

import Foundation
import Network
import RxSwift

public enum LegalServiceType: String {
    case electronicStatementsEmail = "ACCTS_ESTATEMENTS_EMAIL"
    case electronicStatementsPDF = "ACCTS_ESTATEMENTS_PDF"
    case stopPayment = "ACCTS_STOP_PAYMENT"
    case application = "APPLICATION"
    case biometricAuthentication = "BIOMETRIC_AUTHENTICATION"
    case moneyMovementACH = "MM_ACH"
    case moneyMovementBillPay = "MM_BILLPAY"
    case moneyMovementBillENR = "MM_BILLPAY_ENR"
    case moneyMovementPayP2P = "MM_P2P"
    case moneyMovementPayRDC = "MM_RDC"
    case moneyMovementPayTransfer = "MM_TRANSFER"
    case moneyMovementWire = "MM_WIRE"
    case mobileAccess = "MOBILE_ACCESS"
    case mobileApplication = "MOBILE_APPLICATION"
    case mobileSnapshot = "MOBILE_SNAPSHOT"
    case overdraftProtection = "OVERDRAFT_PROTECTION"

    // Edocs
    case notices = "E_ACCOUNT_NOTICE"
    case goPaperless = "ACCTS_ESTATEMENTS_GO_PAPERLESS"
    case estatements = "ACCTS_ESTATEMENTS"
    case taxDocs = "E_TAX_DOCUMENTS"
}

public protocol LegalContentService {
    func retrieveDisclosure(legalServiceType: LegalServiceType) -> Single<DisclosureResponse>
}
