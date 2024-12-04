import UIKit
import Combine

class NetworkClient {
    static let shared = NetworkClient()
    private init(){}
    
    func fetchItems(page: Int) -> AnyPublisher<[Item], Error> {
        let urlString = "https://api.github.com/search/repositories?q=swift&sort=stars&order=asc&page=\(page)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: GitHubResponse.self, decoder: JSONDecoder())
            .map{response in
                response.items.map{
                    Item(name: $0.name, description: $0.description ?? "", avatarUrl: $0.owner.avatar_url)
                }
            }
            .eraseToAnyPublisher()
    }
}
