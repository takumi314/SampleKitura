//
//  PublicRoutes.swift
//  
//
//  Created by NishiokaKohei on 11/04/2020.
//

import Kitura
import LoggerAPI
import Foundation

func initializePublicRoutes(app: App) {
    // 1.
    app.router.all("/public", middleware: BodyParser())
    // 2. Handle HTTP request to '/public'
    app.router.post("/public", handler: app.postPublicHandler(_:_:_:))
    // 3. 
    app.router.all("/public", middleware: StaticFileServer())
}

extension App {

    func postPublicHandler(_ request: RouterRequest, _ response: RouterResponse, _ next: @escaping () -> Void) throws {
        Log.verbose("body >>>>> \(request.body.debugDescription)")
        guard let parsedBody = request.body else { return next() }

        switch(parsedBody) {
        case .multipart(let parts):
            for part in parts {
                switch part.body {
                case .raw(let file):
                    Log.verbose("data >>>>> \(String(data: file, encoding: .utf8) ?? "This is not a Text file")")
                    response.send("data >>>>> ok\n")
                case .text(let text):
                    Log.verbose("text >>>>> \(text)")
                    response.send("text >>>>> ok\n")
                default:
                    break
                }
            }
        case .text(let text):
            Log.verbose("text >>>>> \(text)")
            response.send("text >>>>> \(text)\n")
        default:
            response.send(parsedBody.asURLEncoded?.debugDescription ?? "")
        }

        try response.send("ok\n").end()
        next()
    }

}

private func importPKCS12(_ fileData: Data, _ password: String, _ handler: @escaping (SecIdentity?, OSStatus) -> Void) throws {
    let options = [kSecImportExportPassphrase as String: password]
    var rawItems: CFArray?
    let status = SecPKCS12Import(fileData as CFData, options as CFDictionary, &rawItems)

    guard status == errSecSuccess else {
        Log.info("failed importing p12 file. [status: \(status)] \np12_importer {file_path} [-p] {password}")
        return handler(nil, status)
    }
    guard let items = rawItems as? Array<Dictionary<String, Any>> else {
        return handler(nil, status)
    }
    let firstItem = items[0]
    let identity = firstItem[kSecImportItemIdentity as String] as! SecIdentity

    Log.info("identity: \(identity)")
    handler(identity, status)
}
