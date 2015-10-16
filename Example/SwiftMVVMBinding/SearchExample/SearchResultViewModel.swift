//
//  SearchResultViewModel.swift
//  SwiftMVVMBinding
//
//  Created by Darren Clark on 2015-10-16.
//  Copyright © 2015 Darren Clark. All rights reserved.
//

import Foundation

class SearchResultViewModel {
    
    let emoji: String
    let name: String
    
    init(emoji: String, name: String) {
        self.emoji = emoji
        self.name = name
    }
    
}
