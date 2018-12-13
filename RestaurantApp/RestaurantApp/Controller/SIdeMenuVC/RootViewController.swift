//
//  RootViewController.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 18/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

public extension KVSideMenu{
    
    static public let leftSideViewController   =  "SideMenuViewController"
    
    struct RootsIdentifiers{
        static public let initialViewController  =  "homeSegue"
        // All roots viewcontrollers
        static public let firstViewController    =  "homeSegue"
    }
}

class RootViewController: KVRootBaseSideMenuViewController {

    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        leftSideMenuViewController  =  self.storyboard?.instantiateViewController(withIdentifier: KVSideMenu.leftSideViewController)
        self.menuContainerView?.animationType = KVSideMenu.AnimationType.folding
        self.changeSideMenuViewControllerRoot(KVSideMenu.RootsIdentifiers.initialViewController)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

