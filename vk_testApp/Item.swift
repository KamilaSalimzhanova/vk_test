import Foundation

struct GitHubResponse: Codable {
    let items: [GitHubItem]
}

struct GitHubItem: Codable {
    let name: String
    let description: String?
    let owner: Owner
    
    struct Owner: Codable {
        let avatar_url: String
    }
}

struct Item {
    let name: String
    let description: String
    let avatarUrl: String
}

