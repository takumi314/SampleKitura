//
//  PublicRoutes.swift
//  
//
//  Created by NishiokaKohei on 11/04/2020.
//

import Kitura
import LoggerAPI
import Security
import Foundation.NSError

func initializePublicRoutes(app: App) {
    // 1.
    app.router.all("/public", middleware: BodyParser())
    // 2. Handle HTTP request to '/public'
    app.router.post("/public", handler: app.postPublicHandler(_:_:_:))
    // 3. 
    app.router.all("/public", middleware: StaticFileServer())
}

extension App {

    func postPublicHandler(_ request: RouterRequest,
                           _ response: RouterResponse,
                           _ next: @escaping () -> Void) throws {
        Log.verbose("body >>>>> \(request.body.debugDescription)")
        guard let parsedBody = request.body else { return next() }

        switch(parsedBody) {
        case .multipart(let parts):
            try multipart(parts) { fineName, error in
                response.send("file: \(fineName)\n")
                if let error = error {
                    response.send("\(error)\n")
                } else {
                    response.send("Success\n")
                }
                try response.send("Completed\n").end()
                next()
            }
        default:
            response.send(parsedBody.asURLEncoded?.debugDescription ?? "")
            try response.send("ok\n").end()
            next()
        }

    }

}

private func multipart(_ parts: [Part],
                       _ completion: @escaping ((_ filename: String, Error?) throws -> Void)) throws {
    guard let p12File = filterPKCS12(from: parts), let p12Data = p12File.data else {
        try completion("No file", NSError(domain: "File Format", code: -9_999))
        return Log.verbose("data >>>>> This is not PKCS12 format.\n")
    }
    let password = filterPassword(from: parts) ?? ""
    Log.verbose("password >>>>> \(password.map { _ in "*" }.joined())\n")
    do {
        try importPKCS12(p12Data, password) { isSuccess, osStatus in
            Log.debug("\(isSuccess ? "Success": "Failed"), [OSStutus: \(osStatus)]")
            if isSuccess {
                try completion(p12File.name, nil)
            } else {
                try completion(p12File.name, NSError(domain: "OSStatus", code: Int(osStatus)))
            }
        }
    } catch {
        try completion(p12File.name, error)
    }
}

private func filterPKCS12(from parts: [Part]) -> (name: String, data: Data?)? {
    return parts
        .filter { $0.name == "submitfile" && $0.filename.hasSuffix(".p12") }
        .compactMap { ($0.filename, $0.body.asRaw) }
        .first
}

private func filterPassword(from parts: [Part]) -> String? {
    return parts
        .filter { $0.name == "password" }
        .compactMap { $0.body.asText }
        .first
}

private func importPKCS12(_ fileData: Data,
                          _ password: String,
                          _ handler: @escaping (Bool, OSStatus) throws -> Void) throws {
    let options = [kSecImportExportPassphrase as String: password]
    var rawItems: CFArray?
    let status = SecPKCS12Import(fileData as CFData, options as CFDictionary, &rawItems)
    guard status == errSecSuccess else {
        Log.info("failed importing p12 file. [status: \(status)] \n")
        return try handler(false, status)
    }
    guard let items = rawItems as? Array<Dictionary<String, Any>> else {
        return try handler(false, status)
    }
    let firstItem = items[0]
    // let identity = firstItem[kSecImportItemIdentity as String] as! SecIdentity
    Log.info("\(firstItem.debugDescription)")
    try handler(true, status)
}
