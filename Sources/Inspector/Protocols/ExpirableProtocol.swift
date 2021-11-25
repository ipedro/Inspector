import Foundation

protocol ExpirableProtocol {
    static var delay: TimeInterval { get }
    
    var expirationDate: Date { get }
    var identifier: UUID { get }
}

extension ExpirableProtocol {
    var delay: TimeInterval { Inspector.configuration.snapshotExpirationTimeInterval }
    var isValid: Bool { expirationDate > Date() }
    var isExpired: Bool { !isValid }
}
