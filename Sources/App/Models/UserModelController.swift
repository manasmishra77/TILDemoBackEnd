
import Vapor

struct UserModelController: RouteCollection {
    func boot(router: Router) throws {
        let userRoute = router.grouped("api", "users")
        userRoute.get(use: getAllHandlers)
        userRoute.get(UserModel.parameter, use: getHandler)
        userRoute.post(UserModel.self, use: createHandler)
        userRoute.delete(UserModel.parameter, use: deleteHandler)
        userRoute.put(UserModel.parameter, use: updateHandler)
    }
    
    func getAllHandlers(_ req: Request) throws -> Future<[UserModel]> {
        return UserModel.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<UserModel> {
        return try req.parameters.next(UserModel.self)
    }
    
    func createHandler(_ req: Request, user: UserModel) throws -> Future<UserModel> {
        return user.save(on: req)
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(UserModel.self).flatMap(to: HTTPStatus.self) { (user) in
            return user.delete(on: req).transform(to: .noContent)
        }
    }
    
    func updateHandler(_ req: Request) throws -> Future<UserModel> {
        return try flatMap(to: UserModel.self, req.parameters.next(UserModel.self), req.content.decode(UserModel.self)) { (user, updatedUser) in
            user.name = updatedUser.name
            user.userName = updatedUser.userName
            return user.save(on: req)
        }
    }
    
    
    
}
