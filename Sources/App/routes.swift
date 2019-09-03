import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let acronymController = AcronymsController()
    try router.register(collection: acronymController)
    
    let userModelController = UserModelController()
    try router.register(collection: userModelController)
    
    let categoryController = CategoryController()
    try router.register(collection: categoryController)
    
    let websiteController = WebsiteController()
    try router.register(collection: websiteController)
}
