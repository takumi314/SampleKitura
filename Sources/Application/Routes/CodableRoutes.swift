import KituraContracts

// MARK: - Register routes
func initializeCodableRoutes(app: App) {
    app.router.post("/codable", handler: app.postTodoHandler(todo:completion:))
    app.router.get("/codable", handler: app.getAllTodoHnalder(completion:))
    app.router.get("/codable", handler: app.getOneTodoHandler(id:completion:))
}

extension App {

    static var codableStore = [Todo]()

    // MARK: -  Handlers

    func postTodoHandler(todo: Todo, completion: (Todo?, RequestError?) -> Void) {
        execute {
            App.codableStore.append(todo)
        }
        completion(todo, nil)
    }

    func getAllTodoHnalder(completion: @escaping ([Todo], RequestError?) -> Void) {
        execute {
            completion(App.codableStore, nil)
        }
    }

    func getOneTodoHandler(id: Int, completion: @escaping (Todo?, RequestError?) -> Void) {
        execute {
            guard 0 <= id && id < App.codableStore.count && App.codableStore.contains(where: { $0.id == id }) else {
                return completion(nil, RequestError.notFound)
            }
            completion(App.codableStore[id], nil)
        }
    }

}
