import Kitura
import KituraOpenAPI
import LoggerAPI

public class App {

    let router = Router()

    public init() throws {
        Log.info("Hello World")
    }

    func postInit() throws {
        router.all("/public", middleware: StaticFileServer())
        KituraOpenAPI.addEndpoints(
            to: router,
            with: KituraOpenAPIConfig(apiPath: "/openapi", swaggerUIPath: "/openapi/ui")
        )
    }

    public func run() throws {
        try postInit()
        Kitura.addHTTPServer(onPort: 8080, with: router)
        Kitura.run()
    }
}
