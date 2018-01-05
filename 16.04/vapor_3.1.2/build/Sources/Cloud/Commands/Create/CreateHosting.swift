public final class CreateHosting: Command {
    public let id = "hosting"
    
    public let signature: [Argument] = [
        Option(name: "app", help: [
           "The application to which hosting will be added"
        ]),
        Option(name: "gitURL", help: [
            "The Git URL to clone when deploying this application",
            "Note: must be in the SSH format (starting with git@...)"
        ]),
    ]
    
    public let help: [String] = [
        "Adds hosting service to an application."
    ]
    
    public let console: ConsoleProtocol
    public let cloudFactory: CloudAPIFactory
    
    public init(_ console: ConsoleProtocol, _ cloudFactory: CloudAPIFactory) {
        self.console = console
        self.cloudFactory = cloudFactory
    }
    
    public func run(arguments: [String]) throws {
        _ = try createHosting(with: arguments)
    }
    
    func createHosting(with arguments: [String]) throws -> Hosting {
        console.pushEphemeral()

        console.info("Hosting service")
        console.print("The hosting service allows you to deploy code to Vapor Cloud.")
        console.print("You can add additional addons to the hosting service, like")
        console.print("private or shared databases and Redis caches.")

        let app = try console.application(for: arguments, using: cloudFactory)
        
        console.pushEphemeral()
        
        let gitURL: String
        if let n = arguments.option("gitURL") {
            gitURL = n
        } else {
            if console.gitInfo.isGitProject() {
                console.print("Detected Git, to manually choose a URL use the --gitURL option.")
                gitURL = try console.giveChoice(title: "Which Git URL?", in: console.gitInfo.remoteUrls())
            } else {
                console.warning("Git URL's must be in SSH format (git@github.com:...)")
                gitURL = console.ask("What Git URL should we clone when deploying?")
            }
        }
        
        console.popEphemeral()
        
        console.detail("git url", gitURL)
        
        try console.verifyAboveCorrect()
        
        let hosting = Hosting(
            id: nil,
            application: .model(app),
            gitURL: gitURL
        )

        console.popEphemeral()

        return try console.loadingBar(title: "Adding hosting service to '\(app.repoName)'") {
            return try cloudFactory
                .makeAuthedClient(with: console)
                .create(hosting)
        }
    }
}
