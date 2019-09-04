
import Vapor

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        router.get(use: indexHandler)
        router.get("acronyms", Acronym.parameter, use: acronymHandler)
        router.get("user", UserModel.parameter, use: userHandler)
        
    }
    
    func indexHandler(_ req: Request) throws -> Future<View> {
        return Acronym.query(on: req).all().flatMap(to: View.self) { (acronyms) in
            let context = IndexContent(title: "Homepage", acronyms: acronyms)
            return try req.view().render("index", context)
        }
//        let context = IndexContent(title: "HomePage")
//        return try req.view().render("index", context)
    }
    
    func acronymHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Acronym.self).flatMap(to: View.self, { (acronym) in
            return acronym.user.get(on: req).flatMap(to: View.self) { (user) in
                let acronymContext = AcronymContext(title: acronym.long, acronym: acronym, user: user)
                return try req.view().render("acronym", acronymContext)
            }
        })
    }
    
    func userHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(UserModel.self).flatMap(to: View.self, { (user) in
            let context = try UserContext(title: user.name, user: user, acronyms: user.acronyms.query(on: req).all())
            return try req.view().render("user", context)
        })
    }
    
}

struct IndexContent: Encodable {
    let title: String
    let acronyms: [Acronym]?
}

struct AcronymContext: Encodable {
    let title: String
    let acronym: Acronym
    let user: UserModel
}
struct UserContext: Encodable {
    let title: String
    let user: UserModel
    let acronyms: Future<[Acronym]>
}
