import UIKit
import RealmSwift
import ChameleonFramework

// MARK: - TodoListViewController
class TodoListViewController: SwipeTableViewController {

    // MARK: - Properties
    let realm = try! Realm()
    var itemArray: Results<Item>?
    var selectedCategory: ToDoCategory? {
        didSet {
            loadItems()
            tableView.rowHeight = 80
        }
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        if let hexCode = selectedCategory?.hexCode {
            title = selectedCategory?.name
            guard let navBar = navigationController?.navigationBar else {
                fatalError("Navigation controller does not exist")
            }
            
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            
            appearance.backgroundColor = UIColor(hexString: hexCode)
            navBar.standardAppearance = appearance
            navBar.scrollEdgeAppearance = appearance
            navBar.topItem?.backButtonTitle = selectedCategory?.name
        }
    }

    // MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = itemArray?[indexPath.row] {
            configureCell(cell, with: item)
        } else {
            cell.textLabel?.text = "No Item"
            cell.accessoryType = .none
        }

        return cell
    }

    // Helper method to configure the cell
    private func configureCell(_ cell: UITableViewCell, with item: Item) {
        cell.textLabel?.text = item.title
        cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: item.hexCode)!, returnFlat: true)
        cell.accessoryType = item.done ? .checkmark : .none
        applyGradientToCell(cell: cell, item: item)
    }
    
    // MARK: - Gradient Uygulama Fonksiyonu
    func applyGradientToCell(cell: UITableViewCell, item: Item) {
        // Eğer gradient katmanı varsa boyutunu güncelle
        if let primaryColor = UIColor(hexString: item.hexCode) {
            let gradientColors = primaryColor.darken(byPercentage: 0.3)
            cell.backgroundColor = gradientColors
        }
    }

    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = itemArray?[indexPath.row] {
            toggleItemCompletion(item)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // Helper method to toggle item completion status
    private func toggleItemCompletion(_ item: Item) {
        performRealmWrite {
            item.done.toggle()
        }
        tableView.reloadData()
    }
    
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = self.itemArray?[indexPath.row] {
            self.performRealmDelete {
                self.realm.delete(item)
            }
        } else {
            print("Item not found")
        }
    }

    // MARK: - Add New Item
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        presentNewItemAlert()
    }

    // Helper method to present alert for adding a new item
    private func presentNewItemAlert() {
        var textField = UITextField()

        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { _ in
            guard let newItemTitle = textField.text, !newItemTitle.isEmpty else { return }
            self.addNewItem(title: newItemTitle)
        }

        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }

        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    // Helper method to add new item to the selected category
    private func addNewItem(title: String) {
        if let category = selectedCategory {
            let newItem = Item()
            newItem.title = title
            newItem.hexCode = UIColor.randomFlat().hexValue()
            
            performRealmWrite {
                category.itemList.append(newItem)
            }
        }
        tableView.reloadData()
    }

    // MARK: - Data Manipulation Methods
    func loadItems() {
        itemArray = selectedCategory?.itemList.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    func performRealmWrite(_ block: () -> Void) {
        try! realm.write {
            block()
        }
    }
    
    func performRealmDelete(_ block: () -> Void) {
        do {
            try realm.write {
                block()
            }
        } catch {
            print("Realm delete transaction failed: \(error.localizedDescription)")
        }
    }
}

// MARK: - UISearchBarDelegate Methods
extension TodoListViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            searchItems(with: searchText)
        }
    }

    // Helper method to search items
    private func searchItems(with query: String) {
        if let category = selectedCategory {
            itemArray = category.itemList.filter("title CONTAINS[cd] %@", query)
                .sorted(byKeyPath: "dateCreated", ascending: false)
        }
        tableView.reloadData()
    }
}
