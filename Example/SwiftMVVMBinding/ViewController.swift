//
//  ViewController.swift
//  Bindings
//
//  Created by Darren Clark on 2015-10-13.
//  Copyright © 2015 Darren Clark. All rights reserved.
//

import UIKit

class ViewController : UIViewController {
    
    let viewModel = TweetViewModel()
    
    @IBOutlet var tweetBody: UITextField!
    @IBOutlet var postButton: UIButton!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var characterCountLabel: UILabel!
    
    override func viewDidLoad() {
        tweetBody.b_text = viewModel.tweetBody
        statusLabel.b_text = viewModel.statusMessage
        characterCountLabel.b_text = viewModel.charactersLeft
        
        postButton.b_enabled = viewModel.canSubmitTweet
        postButton.b_onTap(viewModel.postTweet)
    }
    
}

