//
//  String+Validations.swift
//  Pods
//
//  Created by Padmanabhuni Bhaskaruni, Nagasri Sai Swetha on 1/6/21.
//

import Foundation

public extension String {
    
    func isValidEmail() -> Bool {
        let email = self
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isValidPhone() -> Bool {
        let phone = self
        let regularExpressionForPhone = "^\\d{10}$"
          let testPhone = NSPredicate(format: "SELF MATCHES %@", regularExpressionForPhone)
        return testPhone.evaluate(with: phone)
    }
}
