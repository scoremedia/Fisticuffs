//
//  ViewController.swift
//  Bindings
//
//  Created by Darren Clark on 2015-10-13.
//  Copyright © 2015 Darren Clark. All rights reserved.
//

import UIKit

class TweetViewController : UIViewController {
    
    let viewModel = TweetViewModel()
    
    @IBOutlet var tweetBody: UITextField!
    @IBOutlet var postButton: UIButton!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var characterCountLabel: UILabel!

    
    override func viewDidLoad() {
        tweetBody.b_text.bind(viewModel.tweetBody)
        statusLabel.b_text.bind(viewModel.statusMessage)
        characterCountLabel.b_text.bind(viewModel.charactersLeft)
        
        postButton.b_enabled.bind(viewModel.canSubmitTweet)
        postButton.b_onTap.subscribe(viewModel.postTweet)
    }
    
    @IBAction func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

