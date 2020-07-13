//
//  ViewController.swift
//  AppThemeDemo
//
//  Created by Jean Raphael Bordet on 18/05/2020.
//  Copyright © 2020 Jean Raphael Bordet. All rights reserved.
//

import UIKit
import SceneBuilder
import Caprice

class ViewController: UIViewController {
    @IBOutlet var mainCard: UIView!
    @IBOutlet var mainLabel: UILabel!
    
    @IBOutlet var errorCard: UIView!
    @IBOutlet var errorLabel: UILabel!
    
    @IBOutlet var genericButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newMorningStar =
            Alarm.morningStar
                |> Alarm.titleLens *~ "new morning star"
                |> Alarm.enabledLens *~ false
                
        let result = Alarm.morningStar |> ^Alarm.titleLens

        print(result)
        
        mainLabel.text = newMorningStar.title
    }
    
    @IBAction func openDetailTap(_ sender: Any) {
        navigationLink(
            from: self,
            destination: Scene<DetailViewController>(),
            completion: { _ in },
            isModal: true
        )        
    }
}
