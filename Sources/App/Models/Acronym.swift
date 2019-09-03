
import FluentMySQL
import Vapor

final class Acronym: Codable {
    var id: Int?
    var short: String
    var long: String
    var userID: UserModel.ID
    
    init(short: String, long: String, userID: UserModel.ID) {
        self.short = short
        self.long = long
        self.userID = userID
    }
}

//extension Acronym: Model {
//    typealias Database = SQLiteDatabase
//    typealias ID = Int
//    static let idKey: IDKey = \Acronym.id
//}

extension Acronym: MySQLModel {
    
}

extension Acronym: Content {
    
}
extension Acronym: Migration {
    
}
extension Acronym: Parameter {}

extension Acronym {
    var user: Parent<Acronym, UserModel> {
        return parent(\.userID)
    }
    
    var categories: Siblings<Acronym, Category, AcronymCategoryPivot> {
        return siblings()
    }
}
