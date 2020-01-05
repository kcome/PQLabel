//
//  ViewController.swift
//  PQLabelDemo
//
//  Created by harry on 5/1/20.
//  Copyright © 2020 Harry. All rights reserved.
//

import UIKit
import PQLabel

class ViewController: UIViewController {

    @IBOutlet weak var label: PQLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.label.price = 31234.56
        DispatchQueue(label: "").async {
            while (true) {
                Thread.sleep(forTimeInterval: 2.0)
                let rand = (Double(arc4random()) / 0xFFFFFFFF) * (31234 - 31236) + 31234
                let rounded = round(rand * 100.0) / 100.0
                DispatchQueue.main.async {
                    self.label.price = rounded
                }
            }
        }
    }

}

