import UIKit
import Kingfisher

final class RepositoryCell: UITableViewCell {
    static let reuseIdentifier = "RepositoryCell"
    let cache = ImageCache.default
    
    let RepositoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0 
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configCellImage(photo: String, name: String, description: String) {
        
        cache.clearMemoryCache()
        cache.clearDiskCache()
        
        nameLabel.text = name
        descriptionLabel.text = description
        
        guard let imageUrl = URL(string: photo) else {
            print("Image URL is empty or invalid: \(photo)")
            return
        }
        
        RepositoryImageView.kf.indicatorType = .activity
        RepositoryImageView.kf.setImage(with: imageUrl) { result in
            switch result {
            case .success(let image):
                self.RepositoryImageView.contentMode = .scaleAspectFit
                self.RepositoryImageView.image = image.image
            case .failure(let error):
                print("Error loading image: \(error.localizedDescription)")
            }
        }
    }
    
    private func setupUI() {
        [RepositoryImageView, nameLabel, descriptionLabel].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            RepositoryImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            RepositoryImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            RepositoryImageView.widthAnchor.constraint(equalToConstant: 50),
            RepositoryImageView.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.leadingAnchor.constraint(equalTo: RepositoryImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: RepositoryImageView.trailingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    static func clear() {
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
        cache.cleanExpiredMemoryCache()
        cache.backgroundCleanExpiredDiskCache()
    }
}
