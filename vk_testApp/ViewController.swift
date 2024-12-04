import UIKit
import Combine
import ProgressHUD

final class ViewController: UIViewController {
    
    private var items: [Item] = []
    private var currentPage = 1
    private var tableView: UITableView!
    private var cancellables: Set<AnyCancellable> = []
    private let networkClient = NetworkClient.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
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
    }
    
    private func fetchItems(page: Int) {
        ProgressHUD.show()
        networkClient.fetchItems(page: page).subscribe(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                ProgressHUD.dismiss()
                switch completion {
                case .failure(let error):
                    print("Error in fetching items: \(error)")
                case .finished:
                    print("Finished fetching items for page \(page).")
                }
            }, receiveValue: { [weak self] items in
                self?.items.append(contentsOf: items)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            })
            .store(in: &cancellables)
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == items.count - 1 {
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
        return items.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryCell.reuseIdentifier, for: indexPath) as? RepositoryCell else {
            return UITableViewCell()
        }
        let item = items[indexPath.row]
        cell.configCellImage(photo: item.avatarUrl, name: item.name, description: item.description)
        return cell
    }
}
