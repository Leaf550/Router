//
//  Device.swift
//  Util
//
//  Created by 方昱恒 on 2022/2/27.
//

import UIKit

public class Screen {
    
    public static var isIPhoneX: Bool {
        UIApplication.shared.keyWindow?.safeAreaInsets != UIEdgeInsets.zero
    }
    
    public static var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    public static var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    
    public static var statusBarHeight: CGFloat {
        isIPhoneX ? 44 : 20
    }
    
    public static var navigationBarHeight: CGFloat {
        44
    }
    
    public static var totalTopHeight: CGFloat {
        statusBarHeight + navigationBarHeight
    }
    
    public static var bottomHomeBarHeight: CGFloat {
        isIPhoneX ? 34 : 0
    }
    
    public static var tabBarHeight: CGFloat {
        49
    }
    
    public static var totalBottomHeighr: CGFloat {
        bottomHomeBarHeight + tabBarHeight
    }

}
