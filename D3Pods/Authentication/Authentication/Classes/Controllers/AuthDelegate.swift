//
//  AuthDelegate.swift
//  Authentication
//
//  Created by Andrew Watt on 7/11/18.
//

import Foundation
import Navigation
import Session

public protocol AuthViewController: class {
    var delegate: AuthDelegate? { get set }
    var navigationController: UINavigationController? { get }
}

public enum BiometricEnrollment {
    case none
    case enroll
    case reEnroll
}

public protocol AuthDelegate: class {
    func authViewControllerAuthenticated(_: AuthViewController, completionHandler: @escaping(UserSession) -> Void)
    func authViewController(_: AuthViewController,
                            receivedAdditionalChallenge: ChallengeResponse,
                            receivedAdditionalMFAEnrollResponse mfaEnrollResponse: MFAEnrollmentResponse?,
                            shouldSaveUsernameEnabled: Bool?,
                            username: String?)
    func authViewControllerCanceled(_: AuthViewController)
    func authViewControllerBackActionTaken(_: AuthViewController)
    func authViewControllerNeedsBiometricEnrollment(_ enrollmentType: BiometricEnrollment)
}
