import Kitura
import KituraOpenAPI
import LoggerAPI
import Dispatch

public class App {

    let router = Router()
    let workerQueue = DispatchQueue(label: "worker")

    public init() throws {
        Log.info("Hello World")
    }

    func postInit() throws {
        initializeCodableRoutes(app: self)
        router.all("/public", middleware: StaticFileServer())
        KituraOpenAPI.addEndpoints(
            to: router,
            with: KituraOpenAPIConfig(apiPath: "/openapi", swaggerUIPath: "/openapi/ui")
        )
    }

    func execute(_ block: @escaping (() -> Void)) {
        workerQueue.async {
            block()
        }
    }

    public func run() throws {
        try postInit()
        Kitura.addHTTPServer(onPort: 8080, with: router)
        Kitura.run()
    }
}
