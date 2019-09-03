
import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    func boot(router: Router) throws {
        let acronymRoute = router.grouped("api", "acronyms")
        acronymRoute.get(use: getAllHandlers)
        acronymRoute.post(Acronym.self, use: creatHandler)
        acronymRoute.get(Acronym.parameter, use: getHandler)
        acronymRoute.delete(Acronym.parameter, use: deleteHandler)
        acronymRoute.put(Acronym.parameter, use: updateHandler)
        acronymRoute.get(Acronym.parameter, "categories", use: getCategoriesHandler)
        acronymRoute.post(Acronym.parameter, "categories", Category.parameter, use: addCategoriesHandler)
        acronymRoute.get("search", use: searchHandler)
    }
    
    func getAllHandlers(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<Acronym> {
        return try req.parameters.next(Acronym.self)
    }
    
    func creatHandler(_ req: Request, acronym: Acronym) throws -> Future<Acronym> {
        return acronym.save(on: req)
    }
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Acronym.self).flatMap(to: HTTPStatus.self, { acronym in
            return acronym.delete(on: req).transform(to: .noContent)
        })
    }
    func updateHandler(_ req: Request) throws -> Future<Acronym> {
        return try flatMap(to: Acronym.self, req.parameters.next(Acronym.self), req.content.decode(Acronym.self)) {(acronym, updatedAcronym) in
            acronym.short = updatedAcronym.short
            acronym.long = updatedAcronym.long
            return acronym.save(on: req)
        }
    }
    
    func getCategoriesHandler(_ req: Request) throws -> Future<[Category]> {
        return try req.parameters.next(Acronym.self).flatMap(to: [Category].self, { (acronym) in
            return try acronym.categories.query(on: req).all()
        })
    }
    
    func addCategoriesHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self, req.parameters.next(Acronym.self), req.parameters.next(Category.self), { (acronym, category) in
            let pivot = try AcronymCategoryPivot(acronym.requireID(), category.requireID())
            return pivot.save(on: req).transform(to: .ok)
        })
    }
    
    func searchHandler(_ req: Request) throws -> Future<[Acronym]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return Acronym.query(on: req).group(.or) { (or) in
            or.filter(\.short == searchTerm)
            or.filter(\.long == searchTerm)
        }.all()

    }
    
    
    
}
