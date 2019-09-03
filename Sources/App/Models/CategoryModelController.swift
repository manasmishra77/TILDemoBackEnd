

import Vapor

struct CategoryController: RouteCollection {
    func boot(router: Router) throws {
        let categoryRoute = router.grouped("api", "categories")
        categoryRoute.get(use: getAllHandlers)
        categoryRoute.get(Category.parameter, use: getHandler)
        categoryRoute.post(Category.self, use: createHandler)
        categoryRoute.delete(Category.parameter, use: deleteHandler)
        categoryRoute.put(Category.parameter, use: updateHandler)
        categoryRoute.get(Category.parameter, "acronyms", use: getAcronymsHandler)
    }
    
    func getAllHandlers(_ req: Request) throws -> Future<[Category]> {
        return Category.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<Category> {
        return try req.parameters.next(Category.self)
    }
    
    func createHandler(_ req: Request, user: Category) throws -> Future<Category> {
        return user.save(on: req)
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Category.self).flatMap(to: HTTPStatus.self) { (user) in
            return user.delete(on: req).transform(to: .noContent)
        }
    }
    
    func updateHandler(_ req: Request) throws -> Future<Category> {
        return try flatMap(to: Category.self, req.parameters.next(Category.self), req.content.decode(Category.self)) { (category, updatedCategory) in
            category.name = updatedCategory.name
            return category.save(on: req)
        }
    }
    
    func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
        return try req.parameters.next(Category.self).flatMap(to: [Acronym].self, { (category) in
            return try category.acronyms.query(on: req).all()
        })
    }
    
    
    
}
