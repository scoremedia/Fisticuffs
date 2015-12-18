//  The MIT License (MIT)
//
//  Copyright (c) 2015 theScore Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import Fisticuffs


class ControlsViewModel {
    
    //MARK: Colors
    
    let red = Observable<Float>(0.1)
    let green = Observable<Float>(0.8)
    let blue = Observable<Float>(0.5)
    
    lazy var color: Computed<UIColor> = Computed { [red = self.red, green = self.green, blue = self.blue] in
        return UIColor(
            red: CGFloat(red.value),
            green: CGFloat(green.value),
            blue: CGFloat(blue.value),
            alpha: 1.0
        )
    }
    
    //MARK: Visibility
    
    let alpha = Observable<Float>(1.0)
    let hidden = Observable<Bool>(false)
    
}


class ControlsSampleViewController: UITableViewController {
    
    @IBOutlet var resultsDisplay: UIView!
    
    @IBOutlet var redSlider: UISlider!
    @IBOutlet var greenSlider: UISlider!
    @IBOutlet var blueSlider: UISlider!
    
    @IBOutlet var alphaSlider: UISlider!
    @IBOutlet var hiddenSwitch: UISwitch!
    
    //MARK: -
    
    let viewModel = ControlsViewModel()
    
    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsDisplay.b_backgroundColor <-- viewModel.color
        resultsDisplay.b_alpha.bind(viewModel.alpha, transform: { value in CGFloat(value) })
        resultsDisplay.b_hidden <-- viewModel.hidden
        
        
        redSlider.b_value <-> viewModel.red
        greenSlider.b_value <-> viewModel.green
        blueSlider.b_value <-> viewModel.blue
        
        alphaSlider.b_value <-> viewModel.alpha
        hiddenSwitch.b_on <-> viewModel.hidden
    }
    
}
