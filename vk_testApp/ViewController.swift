import UIKit
import Combine

final class ViewController: UIViewController {
    
    private var items: [Item] = []
    private var currentPage = 1
    private var tableView: UITableView!
    private var cancellables: Set<AnyCancellable> = []
    private let networkClient = NetworkClient.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        print("View did load, setting up the table view.")
        setupTableView()
        fetchItems(page: currentPage)
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RepositoryCell.self, forCellReuseIdentifier: RepositoryCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.isScrollEnabled = true
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        print("Table view has been set up.")
    }
    
    private func fetchItems(page: Int) {
        print("Fetching items for page \(page)...")
        networkClient.fetchItems(page: page).subscribe(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error in fetching items: \(error)")
                case .finished:
                    print("Finished fetching items for page \(page).")
                }
            }, receiveValue: { [weak self] items in
                print("Received \(items.count) items for page \(page).")
                self?.items.append(contentsOf: items) 
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    print("Table view reloaded with new items.")
                }
                print("Table view reloaded with new items.")
            })
            .store(in: &cancellables)
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == items.count - 1 {
            print("Reached the last cell, fetching next page...")
            currentPage += 1
            fetchItems(page: currentPage)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of rows in section \(section): \(items.count)")
        return items.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryCell.reuseIdentifier, for: indexPath) as? RepositoryCell else {
            print("Failed to dequeue a RepositoryCell.")
            return UITableViewCell()
        }
        let item = items[indexPath.row]
        cell.configCellImage(photo: item.avatarUrl, name: item.name, description: item.description)
        print("Configured cell for item at index \(indexPath.row): \(item.name)")
        return cell
    }
}
