//
//  SearchViewModel.swift
//  SwiftMVVMBinding
//
//  Created by Darren Clark on 2015-10-16.
//  Copyright © 2015 Darren Clark. All rights reserved.
//

import Foundation
import SwiftMVVMBinding

class SearchViewModel {
    
    let searchQuery = Observable("")
    
    lazy var results: Computed<[SearchResultViewModel]> = Computed {
        let query = self.searchQuery.value
        let allItems = emojiList
        
        if query.isEmpty {
            return allItems
        }
        else {
            return allItems.filter { model in
                return model.name.rangeOfString(query, options: .CaseInsensitiveSearch, range: nil, locale: nil) != nil
            }
        }
    }
    
    var selections = Observable<[SearchResultViewModel]>([])
    
    lazy var selectionsDisplayString: Computed<String> = Computed {
        let selections = self.selections.value
        if selections.count == 0 {
            return "Try selecting some emojis!"
        }
        else {
            let selectedEmojis = selections.map { vm in vm.emoji }.joinWithSeparator(",")
            return "Selected: \(selectedEmojis)"
        }
    }
    
    
    func deselectAll() {
        selections.value = []
    }
}
