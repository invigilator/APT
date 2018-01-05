import Foundation

/// Stores access and refresh tokens in 
/// a JSON file.
final class TokenCache {
    init() throws {
        try FileManager.default.createVaporConfigFolderIfNecessary()
    }
    
    /// Loads the token cache or throws
    /// an error that login is required
    static func global(with console: ConsoleProtocol) throws -> TokenCache {
        let cache = try TokenCache()
        
        guard try cache.getRefreshToken() != nil else {
            console.info("Welcome to Vapor Cloud!")
            console.print("You need to be logged in to deploy your project.")
            console.print("If you don't already have an account, you can sign up for free.")
            console.detail("Login", "vapor cloud login")
            console.detail("Sign up", "vapor cloud signup")
            throw "Login required"
        }
        
        return cache
    }
    
    /// The JSON file
    var cache: JSON {
        get {
            do {
                let bytes = try DataFile.read(at: tokenPath)
                return try JSON(bytes: bytes)
            } catch {
                // no session read
                return JSON()
            }
        }
        set {
            do {
                let bytes = try newValue.serialize()
                try DataFile.write(bytes, to: tokenPath)
            } catch {
                // could not save session
            }
        }
    }
}

/// Conforms to Cloud API token cache
extension TokenCache: CloudClients.TokenCache {
    func getAccessToken() throws -> AccessToken? {
        guard let access = cache["access"]?.string else {
            return nil
        }
        return try AccessToken(string: access)
    }
    
    func getRefreshToken() throws -> RefreshToken? {
        guard let refresh = cache["refresh"]?.string else {
            return nil
        }
        return RefreshToken(string: refresh)
    }
    
    func setAccessToken(_ accessToken: AccessToken?) throws {
        try cache.set("access", accessToken?.makeString())
    }
    
    func setRefreshToken(_ refreshToken: RefreshToken?) throws {
        try cache.set("refresh", refreshToken?.makeString())
    }
}
