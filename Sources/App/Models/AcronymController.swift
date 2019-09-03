
import Vapor

struct AcronymsController: RouteCollection {
    func boot(router: Router) throws {
        let acronymRoute = router.grouped("api", "acronyms")
        acronymRoute.get(use: getAllHandlers)
        acronymRoute.post(Acronym.self, use: creatHandler)
        acronymRoute.get(Acronym.parameter, use: getHandler)
        acronymRoute.delete(Acronym.parameter, use: deleteHandler)
        acronymRoute.put(Acronym.parameter, use: updateHandler)
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
    
    
    
}
