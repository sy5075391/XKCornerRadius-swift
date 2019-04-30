//
//  ViewController.swift
//  XKCornerRadius-swift
//
//  Created by Jamesholy on 2019/4/29.
//  Copyright © 2019 Jamesholy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var viewewew: UIView!
    @IBOutlet weak var awfaw: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        viewewew.xk_openClip = true
        viewewew.xk_radius = 30
        viewewew.xk_clipType = .topLeft
        
        awfaw.xk_openClip = false
        awfaw.xk_radius = 30
        awfaw.xk_clipType = .topLeft
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        awfaw.xk_clipType = [.bottomLeft,.bottomRight]
        awfaw.xk_openClip = true
        awfaw.xk_forceClip()
    }

    
}

