public final class DatabaseInspect: Command {
    public let id = "credentials"
    
    public let help: [String] = [
        "Get database credentials for a specific application."
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
        console.info("Database credentials")
        
        console.info("")
        console.warning("Be aware, this feature is still in beta!, use with caution")
        console.info("")
        
        let token = try Token.global(with: console)
        let user = try adminApi.user.get(with: token)
        
        let app = try console.application(for: arguments, using: cloudFactory)
        let environments = try applicationApi.environments.all(for: app, with: token)
        let db_token = try ServerTokens(console).token(for: arguments, repoName: app.repoName)
        
        var envArray: [String] = []
        
        try environments.forEach { val in
            envArray.append("\(val.id ?? "")")
        }
        
        try CloudRedis.getDatabaseInfo(
            console: self.console,
            cloudFactory: self.cloudFactory,
            environmentArr: envArray,
            application: app.repoName,
            token: db_token,
            email: user.email
        )
    }
}


