import Kitura

public class App {

    let router = Router()

    public init() throws {

    }

    func postInit() throws {

    }

    public func run() throws {
        try postInit()
        Kitura.addHTTPServer(onPort: 8080, with: router)
        Kitura.run()
    }
}
