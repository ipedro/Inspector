import Foundation

protocol ExpirableProtocol {
    var expirationDate: Date { get }
}

extension ExpirableProtocol {
    var isValid: Bool { expirationDate > Date() }
    var isExpired: Bool { !isValid }
}
