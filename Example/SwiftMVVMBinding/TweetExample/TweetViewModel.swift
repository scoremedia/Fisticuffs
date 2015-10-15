//
//  TweetViewModel.swift
//  Bindings
//
//  Created by Darren Clark on 2015-10-13.
//  Copyright © 2015 Darren Clark. All rights reserved.
//

import SwiftMVVMBinding

class TweetViewModel {
    let tweetBody = Observable("")
    let isLoading = Observable(false)
    let statusMessage = Observable("")
    
    lazy var charactersLeft: Computed<String> = Computed { [weak self] in
        guard let strongSelf = self else { return "" }

        let characterCount = strongSelf.tweetBody.value.characters.count
        if characterCount <= 140 {
            return "\(140 - characterCount)"
        }
        else {
            return "Too long!"
        }
    }
    
    lazy var canSubmitTweet: Computed<Bool> = Computed { [weak self] in
        guard let strongSelf = self else { return false }
        
        let characterCount = strongSelf.tweetBody.value.characters.count
        let loading = strongSelf.isLoading.value
        
        return characterCount > 0 && characterCount <= 140 && loading == false
    }
    
    func postTweet() {
        if tweetBody.value.isEmpty {
            statusMessage.value = "Please enter a tweet!"
            return
        }
        
        isLoading.value = true
        statusMessage.value = "Working..."
        
        FakeTweetService.post(tweetBody.value) { (tweetBodyFromServer: String?) in
            if let unwrapped = tweetBodyFromServer {
                self.statusMessage.value = "Posted!: \(unwrapped)"
            }
            else {
                self.statusMessage.value = "Failed to post :("
            }
            
            self.isLoading.value = false
        }
    }
}
