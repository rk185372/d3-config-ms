//
//  ChallengeServiceItem.swift
//  D3 Banking
//
//  Created by Branden Smith on 11/29/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import Navigation
import Network
import APITransformer
import RxSwift
import RxRelay
import AuthChallengeNetworkInterceptorApi

final class ChallengeServiceItem: ChallengeService {
    weak var delegate: ChallengeServiceDelegate?
    
    private let client: ClientProtocol
    private let challengeServiceBridge: ChallengeServiceBridge
    private let scheduler = ConcurrentDispatchQueueScheduler(qos: .userInitiated)
    private let networkInterceptor: ChallengeNetworkInterceptorItem
    
    init(client: ClientProtocol,
         challengeServiceBridge: ChallengeServiceBridge,
         networkInterceptor: ChallengeNetworkInterceptorItem) {
        self.client = client
        self.challengeServiceBridge = challengeServiceBridge
        self.networkInterceptor = networkInterceptor
        challengeServiceBridge.transformer.setOOBRequestSenderDelegate(delegate: self)
    }
    
    func getChallenge() -> Single<ChallengeResponse> {
        return processResponse(observable: client.request(API.Challenge.challenges()))
    }
    
    func submit(challenge: ChallengeRequest) -> Single<ChallengeResponse> {
        if challenge.type != "NEW_MFA_METHOD_SELECTION" {
            return Single<[String: Any]>
                .create { observable -> Disposable in
                    do {
                        let preparedChallenge = try self.challengeServiceBridge.prepareSubmitRequest(challenge: challenge)
                        observable(.success(preparedChallenge))
                    } catch {
                        observable(.error(error))
                    }
                    return Disposables.create()
                }
                .subscribeOn(scheduler)
                .flatMap { preparedChallenge in
                    self.sendRequest(challenge: preparedChallenge)
                }
        } else {
            return Single<ChallengeResponse>
                .create { observable -> Disposable in
                    do {
                        let newChallenge = try self.challengeServiceBridge.handleNewMFAMethodSelection(challenge: challenge)
                        let data = newChallenge.data(using: .utf8)!
                        
                        let challengeResponse = try JSONDecoder().decode(ChallengeResponse.self, from: data)
                        
                        observable(.success(challengeResponse))
                    } catch {
                        observable(.error(error))
                    }
                    return Disposables.create()
                }
                .subscribeOn(scheduler)
                .observeOn(MainScheduler.instance)
        }
    }
    
    func submit(challenge: [String: Any]) -> Single<ChallengeResponse> {
        return sendRequest(challenge: challenge)
    }
    
    func cancel(challenge: [String: Any]) -> Single<Data> {
        return client.request(API.Challenge.cancel(challenge: challenge))
    }
    
    func goBack(from challenge: [String: Any]) -> Single<ChallengeResponse> {
        return processResponse(observable: client.request(API.Challenge.back(challenge: challenge)))
    }
    
    func launchPageItems(profileType: String) -> Single<[LaunchPageItem]> {
        return client.request(API.Challenge.launchPageItems(profileType: profileType)).map { (response) in
            return response.navItems.navItems.compactMap(LaunchPageItem.init(from:))
        }
    }
    
    private func sendRequest(challenge: [String: Any]) -> Single<ChallengeResponse> {
        return networkInterceptor
            .headers(for: delegate?.currentChallengeType())
            .flatMap { headers in
                self.processResponse(observable: self.client.request(API.Challenge.post(challenge: challenge, headers: headers)))
            }
    }
    
    private func processResponse(observable: Single<Data>) -> Single<ChallengeResponse> {
        return observable
            .observeOn(scheduler)
            .map { data in
                try self.challengeServiceBridge.processResults(data: data)
            }
            .observeOn(MainScheduler.instance)
    }
}
extension LaunchPageItem {
    init?(from navItem: LaunchItemsResponse.NavItems.NavItem) {
        let type: LaunchPageItemType
        if navItem.url == "nativeGeo" {
            type = .locations
        } else if let urlString = navItem.url, let url = URL(string: urlString) {
            type = .webView(url: url)
        } else if let number = navItem.phone {
            type = .phone(number: number)
        } else {
            return nil
        }
        self.init(name: navItem.item, type: type)
    }
}
extension ChallengeServiceItem: RequestSenderDelegate {
    func requestSender(_: RequestSender, hasOOBChallenge challenge: String) {
        guard let dataResult = challenge.data(using: .utf8) else { return }
        
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: dataResult, options: [])
            guard let dictResult = jsonResult as? [String: Any] else { return }
            
            _ = networkInterceptor
                .headers(for: delegate?.currentChallengeType())
                .flatMap { headers in
                    self.client.request(API.Challenge.post(challenge: dictResult, headers: headers))
                }
                .subscribe()
        } catch {
            print(error)
        }
    }
}
