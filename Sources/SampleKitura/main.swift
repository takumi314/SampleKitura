import Foundation
import Kitura
import LoggerAPI
import HeliumLogger
import Application

HeliumLogger.use(.debug)
do {
    let app = try App()
    try app.run()
} catch let error {
    Log.error(error.localizedDescription)
}
