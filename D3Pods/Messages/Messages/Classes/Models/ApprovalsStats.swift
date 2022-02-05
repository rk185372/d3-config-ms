import Foundation

public struct ApprovalsStats: Decodable {
    var pending: Int
    let approved: Int
    let canceled: Int
    let expired: Int
    let rejected: Int
    
    enum CodingKeys: String, CodingKey {
        case pending = "PENDING"
        case approved = "APPROVED"
        case canceled = "CANCELLED"
        case expired = "EXPIRED"
        case rejected = "REJECTED"
    }
    
    public init(pending: Int, approved: Int, canceled: Int, expired: Int, rejected: Int) {
        self.pending = pending
        self.approved = approved
        self.canceled = canceled
        self.expired = expired
        self.rejected = rejected
    }
}
