//
//  ViewController.swift
//  LimitTextField_swift
//
//  Created by Xinbo Lian on 2020/7/27.
//  Copyright © 2020 Xinbo Lian. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let tf = LimitTextField(frame: CGRect(x: 20, y: 100, width: 200, height: 50), maxLength: 10, lengthType: .length, inputType: .dotDecimalNumber(2))
        tf.borderStyle = .line
        view.addSubview(tf)
        // Do any additional setup after loading the view.
    }


}

