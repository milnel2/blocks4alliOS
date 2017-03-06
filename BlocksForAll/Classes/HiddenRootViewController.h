//
//  HiddenRootViewController.h
//  OBDragDropTest
//
//  Created by Ivan Bella Lopez on 31/01/2017.
//  Copyright © 2017 Oblong Industries. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HiddenRootViewController : UIViewController

- (instancetype)initWithStatusBarStyle:(UIStatusBarStyle)statusBarStyle animation:(UIStatusBarAnimation)statusBarAnimation hidden:(BOOL)statusBarHidden;

@end
