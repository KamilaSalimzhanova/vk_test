import XCTest
@testable import vk_testApp

class RepositoryCellTests: XCTestCase {
    
    var cell = RepositoryCell(style: .default, reuseIdentifier: RepositoryCell.reuseIdentifier)

    func testCellConfiguration() {
        let photoURL = "https://example.com/image.jpg"
        let name = "Test Repository"
        let description = "This is a test repository description."
        

        cell.configCellImage(photo: photoURL, name: name, description: description)

        XCTAssertEqual(cell.nameLabel.text, name, "Name label should display the correct name.")
        XCTAssertEqual(cell.descriptionLabel.text, description, "Description label should display the correct description.")
    }

    func testCellImageLoading() {
        let photoURL = "https://example.com/image.jpg"
        cell.configCellImage(photo: photoURL, name: "Test", description: "Description")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertNotNil(self.cell.RepositoryImageView.image, "Image should be loaded and not nil.")
        }
    }
}
