import Kitura
import LoggerAPI

public class App {

    let router = Router()

    public init() throws {
        Log.info("Hello World")
    }

    func postInit() throws {
        router.all("/public", middleware: StaticFileServer())
    }

    public func run() throws {
        try postInit()
        Kitura.addHTTPServer(onPort: 8080, with: router)
        Kitura.run()
    }
}
