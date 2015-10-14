//
//  TweetViewModel.swift
//  Bindings
//
//  Created by Darren Clark on 2015-10-13.
//  Copyright © 2015 Darren Clark. All rights reserved.
//

import Bindings

class TweetViewModel {
    let tweetBody = Observable("")
    let canSubmitTweet = Observable(true)
    let statusMessage = Observable("")
    
    func postTweet() {
        if tweetBody.value.isEmpty {
            statusMessage.value = "Please enter a tweet!"
            return
        }
        
        canSubmitTweet.value = false
        statusMessage.value = "Working..."
        
        FakeTweetService.post(tweetBody.value) { (tweetBodyFromServer: String?) in
            if let unwrapped = tweetBodyFromServer {
                self.statusMessage.value = "Posted!: \(unwrapped)"
            }
            else {
                self.statusMessage.value = "Failed to post :("
            }
            
            self.canSubmitTweet.value = true
        }
    }
}
