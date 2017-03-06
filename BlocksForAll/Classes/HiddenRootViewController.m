//
//  HiddenRootViewController.m
//  Mezzanine
//
//  Created by Ivan Bella Lopez on 31/01/2017.
//  Copyright © 2017 Oblong Industries. All rights reserved.
//

#import "HiddenRootViewController.h"

@interface HiddenRootViewController ()

@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@property (nonatomic, assign) UIStatusBarAnimation statusBarAnimation;
@property (nonatomic, assign) BOOL statusBarHidden;

@end

@implementation HiddenRootViewController

- (instancetype)initWithStatusBarStyle:(UIStatusBarStyle)statusBarStyle animation:(UIStatusBarAnimation)statusBarAnimation hidden:(BOOL)statusBarHidden
{
  if (self == [super init])
  {
    _statusBarStyle = statusBarStyle;
    _statusBarAnimation = statusBarAnimation;
    _statusBarHidden = statusBarHidden;
  }
  
  return self;
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
  return _statusBarStyle;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
  return _statusBarAnimation;
}


- (BOOL)prefersStatusBarHidden
{
  return _statusBarHidden;
}

@end
