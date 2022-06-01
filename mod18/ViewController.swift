//
//  ViewController.swift
//  mod18
//
//  Created by Natalia Shevaldina on 24.04.2022.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    let cell = "JsonStruct"
    
    let service = Service()
    var images = [UIImage]()
    var finallyDataArray: [JsonStruct] = []
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 0)
        return tableView
    }()
    
    private lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        return search
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.register(Cell.self, forCellReuseIdentifier: cell)
        tableView.dataSource = self
        tableView.delegate = self
        setupViews()
        setupConstraints()
    }
    
    private func onLoad(_ searchText: String) {
        activityIndicator.startAnimating()
        finallyDataArray.removeAll()
        
        guard let urlApi = URL(string: "https://imdb-api.com/en/API/Search/\(apiKey)/\(searchText)") else {return}
        let task = URLSession.shared.dataTask(with: urlApi) { (data, response, error) in
            guard let data = data else {
                print("Error URLSession.shared.dataTask")
                return
            }
            
            if let dictionaryFromJSON = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any> {
                guard let dataDict = dictionaryFromJSON["results"] as? [[String: Any]] else { return }
                
                for i in dataDict {
                    guard let image = self.service.loadImage(urlString: String(describing: i["image"]!)) else {return}
                    self.finallyDataArray.append(JsonStruct(
                        image: image,
                        title: String(describing: i["title"]!),
                        resultDescription: String(describing: i["description"]!)))
                }
            }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
            }
        }
        
        task.resume()
    }
    
    private func setupViews () {
        view.backgroundColor = .white
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
    }
    
    private func setupConstraints () {
        searchBar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.leading.trailing.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.centerX.equalTo(view)
            make.centerY.equalTo(view)
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        finallyDataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 93
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cell) as? Cell
        let viewModel = finallyDataArray[indexPath.row]
        cell?.configure(viewModel)
        return cell ?? UITableViewCell()
    }
}

extension ViewController: UITableViewDelegate {}

extension ViewController: UISearchBarDelegate {
    
    internal func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard var searchBarText = searchBar.text else { return }
        let symbols: Set<Character> = ["!", ",", "№", "%", ":", "&", "*", "(", ")", "_", "-", "=", "+", ",", "<", ">", ".", "/", "?", "|", "~"]
        searchBarText.removeAll(where: { symbols.contains($0) })
        let searchText = searchBarText.split(separator: " ").joined(separator: "%20")
        onLoad(searchText)
    }
    
}

