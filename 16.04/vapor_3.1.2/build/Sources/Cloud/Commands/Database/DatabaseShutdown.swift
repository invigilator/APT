public final class DatabaseShutdown: Command {
    public let id = "shutdown"
    
    public let help: [String] = [
        "Shutdown your database server. This will keep the data."
    ]
    
    public let signature: [Argument] = [
        Option(name: "app", help: [
            "The slug name of the application to deploy",
            "This will be automatically detected if your are",
            "in a Git controlled folder with a remote matching",
            "the application's hosting Git URL."
            ]),
        Option(name: "token", help: [
            "Token of the database server.",
            "This is the variable you use to connect to the server",
            "e.g.: DB_MYSQL_<NAME>"
            ])
    ]
    
    public let console: ConsoleProtocol
    public let cloudFactory: CloudAPIFactory
    
    public init(_ console: ConsoleProtocol, _ cloudFactory: CloudAPIFactory) {
        self.console = console
        self.cloudFactory = cloudFactory
    }
    
    public func run(arguments: [String]) throws {
        console.info("Shutdown database")
        
        console.info("")
        console.warning("Be aware, this feature is still in beta!, use with caution")
        console.info("")
        
        let app = try console.application(for: arguments, using: cloudFactory)
        let db_token = try ServerTokens(console).token(for: arguments, repoName: app.repoName)
        
        let token = try Token.global(with: console)
        let user = try adminApi.user.get(with: token)

        guard console.confirm("Do you want to shutdown your database server now?") else {
            throw "Cancelled"
        }
        
        try CloudRedis.shutdownDBServer(
            console: self.console,
            application: app.name,
            token: db_token,
            email: user.email
        )
    }
}


