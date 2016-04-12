//
//  LightenViewController.swift
//  BCColorDemo
//
//  Created by Boyce on 4/13/16.
//  Copyright © 2016 Boyce. All rights reserved.
//

import UIKit

class LightenViewController: UIViewController {

    @IBOutlet private weak var view_00: UIView!
    @IBOutlet private weak var view_01: UIView!
    @IBOutlet private weak var view_02: UIView!
    
    @IBOutlet private weak var view_10: UIView!
    @IBOutlet private weak var view_11: UIView!
    @IBOutlet private weak var view_12: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view_01.backgroundColor = view_00.backgroundColor?.bc_lightenByPercentage(0.1)
        view_02.backgroundColor = view_00.backgroundColor?.bc_lightenByPercentage(0.2)
        
        view_11.backgroundColor = view_10.backgroundColor?.bc_darkenByPercentage(0.1)
        view_12.backgroundColor = view_10.backgroundColor?.bc_darkenByPercentage(0.2)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
