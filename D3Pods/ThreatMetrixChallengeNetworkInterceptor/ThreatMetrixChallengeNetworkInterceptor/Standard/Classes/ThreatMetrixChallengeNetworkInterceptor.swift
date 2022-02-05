//
//  ThreatMetrixChallengeNetworkInterceptor.swift
//  ThreatMetrixChallengeNetworkInterceptor
//
//  Created by Chris Carranza on 5/6/19.
//

import Foundation
import AuthChallengeNetworkInterceptorApi
import RxSwift
import TMXProfiling
import CompanyAttributes

final class ThreatMetrixChallengeNetworkInterceptor: ChallengeNetworkInterceptor {

    private let companyAttributes: CompanyAttributesHolder

    private var defenderIsConfigured: Bool

    private lazy var pagesToSendThreatMetrix: Set<String> = {
        return extractPageSet(from: companyAttributes.companyAttributes.value!)
    }()
    
    init(companyAttributes: CompanyAttributesHolder) {
        self.companyAttributes = companyAttributes
        defenderIsConfigured = false
    }
    
    func headers(for challengeType: String?) -> Single<[String: String]?> {
        if !defenderIsConfigured {
            configureDefender()
        }

        guard shouldSendToThreatMetrix(challengeType: challengeType) else {
            return Single.just(nil)
        }
        
        return Single<[String: String]?>.create { observer in
            TMXProfiling.sharedInstance()?.profileDevice(callbackBlock: { results in
                if let sessionID = results?[TMXSessionID] as? String {
                    observer(.success(["tmsid": sessionID]))
                } else {
                    observer(.success(nil))
                }
            })
            
            return Disposables.create()
        }
    }

    private func configureDefender() {
        TMXProfiling
            .sharedInstance()?
            .configure(
                configData: [
                    TMXOrgID: companyAttributes.companyAttributes.value!.value(forKey: "threatmetrix.orgId")! as Any,
                    TMXFingerprintServer: companyAttributes.companyAttributes.value!.value(forKey: "threatmetrix.profilingDomain")! as Any
                ]
            )

        defenderIsConfigured = true
    }
    
    private func shouldSendToThreatMetrix(challengeType: String?) -> Bool {
        guard let challengeType = challengeType else { return false }
        
        return pagesToSendThreatMetrix.contains(challengeType)
    }
    
    private func extractPageSet(from companyAttributes: CompanyAttributes) -> Set<String> {
        let pageIds = companyAttributes.stringValue(forKey: "threatmetrix.pageIdMap")
        let pages: [String] = pageIds.split(separator: ",").map { pair in
            let parts = pair.split(separator: "=")
            
            return String(parts[0].trimmingCharacters(in: .whitespacesAndNewlines))
        }
        return Set(pages)
    }
}
