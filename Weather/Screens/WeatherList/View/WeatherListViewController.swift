//
//  WeatherListViewController.swift
//  Weather
//
//  Created by Anh Tran on 23/09/2021.
//

import UIKit
import RxSwift
import RxCocoa

class WeatherListViewController: BaseViewController {
    
    private typealias DataSource = UITableViewDiffableDataSource<WeatherListViewModel.WeatherSection, WeatherDisplayModel>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<WeatherListViewModel.WeatherSection, WeatherDisplayModel>

    private var disposeBag = DisposeBag()
    private let viewModel: WeatherListViewModelType
    private let search = PublishRelay<String>()
    private let viewDidAppear = PublishRelay<Void>()
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.tintColor = .label
        searchController.searchBar.delegate = self
        Accessibility(label: "Search text field",
                      hint: "Search weather today, just type the city you want to know!", trails: .none)
            .apply(to: searchController.searchBar.searchTextField)
        return searchController
    }()
    
    private lazy var dataSource = configdataSource()
    @IBOutlet weak var tableView: UITableView!
    
    init(viewModel: WeatherListViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: "WeatherListViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        renderUI()
        bindViewModel(viewModel)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppear.accept(())
    }
}

extension WeatherListViewController {
    func renderUI() {
        self.title = "Weather Forecast"
        setupTableView()
        setupSearchUI()
    }
    
    func bindViewModel(_ viewModel: WeatherListViewModelType) {
        let input = WeatherListViewModelInput(loadView: viewDidAppear,
                                          search: search)
        let output = viewModel.transform(input: input)
        
        output.weatherSearchOutput.drive(onNext: { [weak self] state in
            guard let self = self else {return}
            self.updateView(state)
        }).disposed(by: disposeBag)
    }
    
    func updateView(_ state: SearchWeatherState) {
        print("Update view with state: \(state)")
        switch state {
        case .empty:
            self.updateDataSource([])
            self.finishLoading()
            self.tableView.setEmptyMessage("How is the weather?")
        case .loaded(let weatherList):
            self.finishLoading()
            self.updateDataSource(weatherList)
        case .loading:
            self.startLoading()
            break;
        case .haveError(let error):
            self.finishLoading()
            self.showError(error)
        }
    }
}


//MARK: - Weather Tableview
extension WeatherListViewController {
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.dataSource = dataSource
        tableView.register(UINib(nibName: WeatherTableViewCell.className, bundle: nil),
                           forCellReuseIdentifier: WeatherTableViewCell.identifier)
    }
    
    private func configdataSource() -> DataSource {
        return DataSource(
            tableView: tableView,
            cellProvider: {  tableView, indexPath, wetherFactor in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier) as? WeatherTableViewCell else {
                    fatalError("Can not dequeue \(WeatherTableViewCell.self)!")
                }
                cell.bindModel(wetherFactor)
                return cell
            }
        )
    }
    
    private func updateDataSource(_ weatherList: [WeatherDisplayModel]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.weatherList])
        snapshot.appendItems(weatherList, toSection: .weatherList)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
}


//MARK: Search Bar
extension WeatherListViewController: UISearchBarDelegate {
    private func setupSearchUI() {
        searchController.isActive = true
        navigationItem.searchController = self.searchController
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search.accept(searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        search.accept("")
    }
}

extension WeatherListViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchController.searchBar.resignFirstResponder()
    }
}
