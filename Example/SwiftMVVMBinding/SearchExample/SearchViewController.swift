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
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var clearButton: UIBarButtonItem!
    @IBOutlet var selectionDisplay: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.b_text.bind(viewModel.searchQuery)
    
        clearButton.b_onTap.subscribe(viewModel.deselectAll)
        
        collectionView.allowsMultipleSelection = true
        
        collectionView.b_configure(viewModel.results) { config in
            config.usingCellIdentifier("SearchResultCell") { model, cell in
                (cell as! SearchResultCell).bind(model)
            }
            
            config.selections = viewModel.selections
        }

        selectionDisplay.b_text.bind(viewModel.selectionsDisplayString)
    }
    
}
