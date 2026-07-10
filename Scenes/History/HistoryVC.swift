import UIKit

class HistoryVC: UIViewController {
    
    // MARK: - Private Properties
    private let viewModel: HistoryVM
    private let historyTableView = UITableView()
    
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
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Private Methods
    private func navBarConfig() {
        let titleView = UILabel()
        titleView.text = viewModel.getCaseName()
        titleView.textColor = .black
        titleView.font = UIConstants.titleFontPrimary
        navigationItem.titleView = titleView
    }
    
    private func setupTableView() {
        historyTableView.backgroundColor = .clear
        historyTableView.delegate = self
        historyTableView.dataSource = self
        historyTableView.showsVerticalScrollIndicator = false
        historyTableView.separatorInset = UIConstants.tableSeparatorInset
//        historyTableView.separatorStyle = .none
        historyTableView.frame = view.bounds
        
        historyTableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(historyTableView)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        navBarConfig()
        setupTableView()
    }
}

extension HistoryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getHistoryCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "HistoryCell")
        cell.textLabel?.text = viewModel.getEntryDate(at: indexPath.row)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        cell.detailTextLabel?.text = viewModel.getEntryRecord(at: indexPath.row)
        cell.detailTextLabel?.numberOfLines = 10
        return cell
    }
}
