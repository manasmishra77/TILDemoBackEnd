
import Vapor

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        router.get(use: indexHandler)
        router.get("acronyms", Acronym.parameter, use: acronymHandler)
        router.get("user", UserModel.parameter, use: userHandler)
        router.get("users", use: allUsersHandler)
        router.get("categories", use: allCategoriesHandler)
        router.get("category", Category.parameter, use: categoryHandler)
        router.get("acronyms", "create", use: createAcronymHandler)
        router.post(Acronym.self, at: "acronyms", "create", use: createAcronymPostHandler)
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
    
    func allUsersHandler(_ req: Request) throws -> Future<View> {
        return UserModel.query(on: req).all().flatMap(to: View.self) { (users) in
            let context = AllUsersContext(title: "Users", users: users)
            return try req.view().render("users", context)
        }
    }
    
    func allCategoriesHandler(_ req: Request) throws -> Future<View> {
        return Category.query(on: req).all().flatMap(to: View.self) { (categories) in
            let context = AllCategoriesContext.init(title: "Categories", categories: categories)
            return try req.view().render("categories", context)
        }
    }
    
    func categoryHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Category.self).flatMap(to: View.self, { (category) in
            let acronyms = try category.acronyms.query(on: req).all()
            let context = CategoryContext(title: category.name, acronyms: acronyms)
            return try req.view().render("category", context)
        })
    }
    
    func createAcronymHandler(_ req: Request) throws -> Future<View> {
        let context = CreateAcronymContext(users: UserModel.query(on: req).all())
        return try req.view().render("createAcronym", context)
    }
    
    func createAcronymPostHandler(_ req: Request, acronym: Acronym) throws -> Future<Response> {
        return acronym.save(on: req).map { (acronym) in
            guard let id = acronym.id else {
                return req.redirect(to: "/")
            }
            return req.redirect(to: "/acronyms/\(id)")
        }
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

struct AllUsersContext: Encodable {
    let title: String
    let users: [UserModel]
}
struct AllCategoriesContext: Encodable {
    let title: String
    let categories: [Category]
}

struct CategoryContext: Encodable {
    let title: String
    let acronyms: Future<[Acronym]>
}

struct CreateAcronymContext: Encodable {
    let title = "Create An Acronym"
    let users: Future<[UserModel]>
}
