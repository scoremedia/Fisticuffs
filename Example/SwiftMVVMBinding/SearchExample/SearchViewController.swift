//
//  SearchViewController.swift
//  SwiftMVVMBinding
//
//  Created by Darren Clark on 2015-10-16.
//  Copyright © 2015 Darren Clark. All rights reserved.
//

import UIKit


class SearchViewController: UIViewController {
    
    let viewModel = SearchViewModel()
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.b_text = viewModel.searchQuery
        
        tableView.b_configure(viewModel.results) { config in
            config.usingCellIdentifier("SearchResultCell") { model, cell in
                (cell as! SearchResultCell).bind(model)
            }
        }
    }
    
}
