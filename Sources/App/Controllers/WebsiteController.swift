
import Vapor

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        router.get(use: indexHandler)
        
    }
    
    func indexHandler(_ req: Request) throws -> Future<View> {
        return Acronym.query(on: req).all().flatMap(to: View.self) { (acronyms) in
            let context = IndexContent(title: "Homepage", acronyms: acronyms.isEmpty ? nil : acronyms)
            return try req.view().render("index", context)
        }
//        let context = IndexContent(title: "HomePage")
//        return try req.view().render("index", context)
    }
    
}

struct IndexContent: Encodable {
    let title: String
    let acronyms: [Acronym]?
}
