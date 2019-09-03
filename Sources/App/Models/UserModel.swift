
import FluentSQLite
import Vapor
import Foundation

final class UserModel: Codable {
    var id: UUID?
    var name: String
    var userName: String
    
    init(name: String, userName: String) {
        self.name = name
        self.userName = userName
    }
}

extension UserModel: SQLiteUUIDModel {}

extension UserModel: Content {}
extension UserModel: Migration {}
extension UserModel: Parameter {}
