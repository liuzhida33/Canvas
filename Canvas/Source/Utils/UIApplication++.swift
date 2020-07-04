//
//  UIApplication++.swift
//  Canvas
//
//  Created by 刘志达 on 2020/3/31.
//  Copyright © 2020 joylife. All rights reserved.
//

import UIKit.UIApplication

extension UIApplication {
    
    static func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
