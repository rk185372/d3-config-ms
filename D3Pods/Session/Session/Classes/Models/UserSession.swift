//
//  UserSession.swift
//  Accounts
//
//  Created by Branden Smith on 8/2/18.
//

import Foundation
import Utilities
import RxSwift
import RxRelay
import Permissions

public class UserSession {
    fileprivate static func roles(forSession rawSession: RawSession?) -> Set<UserRole> {
        guard let rawSession = rawSession else {
            return []
        }
        return rawSession.profiles[rawSession.selectedProfileIndex].roles
    }

    fileprivate let sessionRelay: BehaviorRelay<RawSession?> = BehaviorRelay(value: nil)
    
    public var rawSession: RawSession? {
        get {
            return sessionRelay.value
        }
        set {
            sessionRelay.accept(newValue)
        }
    }
    
    public var session: Session? {
        return rawSession.map(Session.init(from:))
    }

    public var selectedProfile: UserProfile? {
        guard let selectedProfileIndex = sessionRelay.value?.selectedProfileIndex else {
            return nil
        }
        
        return userProfiles[selectedProfileIndex]
    }
    
    public var userProfiles: [UserProfile] {
        get {
            return rawSession?.profiles ?? []
        }
        set {
            rawSession?.profiles = newValue
        }
    }
    
    public var roles: Set<UserRole> {
        return UserSession.roles(forSession: rawSession)
    }

    public init() {}
    
    public func selectProfile(index: Int) {
        rawSession?.selectedProfileIndex = index
    }
}

extension UserSession: ReactiveCompatible {}

public extension Reactive where Base: UserSession {
    var selectedProfileIndex: Observable<Int?> {
        return base.sessionRelay.map { $0?.selectedProfileIndex }
    }
    
    var session: Observable<Session?> {
        return base.sessionRelay.map { $0.map(Session.init(from:)) }
    }
    
    var userProfiles: [Observable<UserProfile?>] {
        return base.userProfiles.indices.map { (index) in
            return base.sessionRelay.map { (session) in
                return session?.profiles[index]
            }
        }
    }

    var selectedProfile: Observable<UserProfile?> {
        return base.sessionRelay.map({ rawSession in
            guard let session = rawSession else {
                return nil
            }

            guard 0..<session.profiles.count ~= session.selectedProfileIndex else {
                return nil
            }

            return session.profiles[session.selectedProfileIndex]
        })
    }
    
    var roles: Observable<Set<UserRole>> {
        return base.sessionRelay.map(UserSession.roles(forSession:))
    }
    
    var rdcAllowed: Observable<Bool> {
        return base.sessionRelay.map { $0?.rdcAllowed ?? false }
    }
}
