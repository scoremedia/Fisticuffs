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
        let allItems = self.allItems.value
        
        if query.isEmpty {
            return allItems
        }
        else {
            return allItems.filter { model in
                return model.name.rangeOfString(query, options: .CaseInsensitiveSearch, range: nil, locale: nil) != nil
            }
        }
    }
    
    let allItems = ObservableArray<SearchResultViewModel>([
        SearchResultViewModel(emoji: "😄", name: "Smile"),
        SearchResultViewModel(emoji: "😛", name: "Tounge out"),
        SearchResultViewModel(emoji: "😡", name: "Angry"),
        SearchResultViewModel(emoji: "😱", name: "Scared"),
        SearchResultViewModel(emoji: "😺", name: "Smiling Cat"),
        SearchResultViewModel(emoji: "👮", name: "Police Officer"),
        SearchResultViewModel(emoji: "👻", name: "Ghost"),
        SearchResultViewModel(emoji: "💩", name: "Poo"),
        SearchResultViewModel(emoji: "👽", name: "Alien"),
        SearchResultViewModel(emoji: "👍", name: "Thumbs up"),
        SearchResultViewModel(emoji: "🌳", name: "Tree"),
        SearchResultViewModel(emoji: "🐵", name: "Monkey"),
        SearchResultViewModel(emoji: "🐼", name: "Panda"),
        SearchResultViewModel(emoji: "🇨🇦", name: "Canada"),
        SearchResultViewModel(emoji: "🕔", name: "Five o'clock"),
        SearchResultViewModel(emoji: "♥️", name: "Heart"),
        SearchResultViewModel(emoji: "🎉", name: "Party"),
        SearchResultViewModel(emoji: "🍻", name: "Cheers"),
        SearchResultViewModel(emoji: "🍆", name: "Eggplant"),
        SearchResultViewModel(emoji: "🎃", name: "Jack-o-lantern"),
        SearchResultViewModel(emoji: "🎲", name: "Dice"),
        SearchResultViewModel(emoji: "💯", name: "100%"),
        SearchResultViewModel(emoji: "💣", name: "Bomb"),
        SearchResultViewModel(emoji: "🎯", name: "Bullseye"),
        SearchResultViewModel(emoji: "🏉", name: "Football"),
        SearchResultViewModel(emoji: "🍰", name: "Cake"),
        SearchResultViewModel(emoji: "🌝", name: "Full moon"),
        SearchResultViewModel(emoji: "🐙", name: "Octopus"),
        SearchResultViewModel(emoji: "🐦", name: "Bird"),
        SearchResultViewModel(emoji: "🌵", name: "Cactus"),
        SearchResultViewModel(emoji: "👶", name: "Baby"),
    ])
}