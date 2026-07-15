import UIKit

class HistoryVC: UIViewController {
    
    // MARK: - Private Properties
    private let viewModel: HistoryVM
    private let historyTableView = UITableView()
    private let cellReuseIdentifier = "HistoryCell"
    private let tableSeparatorInset: UIEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10)
    
    // MARK: - Initializers
    init(viewModel: HistoryVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Private Methods
    private func bindViewModel() {
        viewModel.historyVCBinding.bind { [weak self] value in
            guard let self = self else { return }
            
            switch value {
            case .removeItem(let indexes):
                self.removeItem(at: indexes)
            default:
                break
            }
        }
    }
    private func navBarConfig() {
        let titleView = UILabel()
        titleView.text = viewModel.getCaseName()
        titleView.textColor = .textPrimary
        titleView.font = .titleFontPrimary
        navigationItem.titleView = titleView
    }
    
    private func setupTableView() {
        historyTableView.backgroundColor = .clear
        historyTableView.delegate = self
        historyTableView.dataSource = self
        historyTableView.showsVerticalScrollIndicator = false
        historyTableView.separatorInset = tableSeparatorInset
        historyTableView.frame = view.bounds
        
        historyTableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(historyTableView)
    }
    
    private func setupUI() {
        view.overrideUserInterfaceStyle = .light
        view.backgroundColor = .white
        navBarConfig()
        setupTableView()
    }
    
    private func removeItem(at indexes: [IndexPath]) {
        historyTableView.performBatchUpdates {
            historyTableView.deleteRows(at: indexes, with: .automatic)
        } completion: { _ in
            self.historyTableView.reloadData()
        }
    }
}

extension HistoryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getHistoryCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellReuseIdentifier)
        cell.backgroundColor = .clear
        cell.textLabel?.text = viewModel.getEntryDate(at: indexPath.row)
        cell.textLabel?.font = .cellLabelFont
        cell.textLabel?.textColor = .textPrimary
        cell.detailTextLabel?.text = viewModel.getEntryRecord(at: indexPath.row)
        cell.detailTextLabel?.font = .buttonsLabelFontTertiary
        cell.detailTextLabel?.textColor = .textTertiary
        cell.detailTextLabel?.numberOfLines = 10
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let primaryAction = UIContextualAction(style: .destructive,
                                               title: .Localized.onboardingVCButtonDelete) { [weak self] (action, view, completionHandler) in
            self?.viewModel.deleteButtonTapped(for: indexPath.row)
            completionHandler(true)
        }
        primaryAction.backgroundColor = .swipeActionBg
        
        return UISwipeActionsConfiguration(actions: [primaryAction])
    }
}
