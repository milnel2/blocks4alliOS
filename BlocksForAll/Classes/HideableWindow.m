//
//  HideableWindow.m
//  Mezzanine
//
//  Created by miguel on 6/12/16.
//  Copyright © 2016 Oblong Industries. All rights reserved.
//

#import "HideableWindow.h"

@interface HideableWindow ()

@property (nonatomic, strong) UIViewController *hiddenRootViewController;

@end

@implementation HideableWindow

// Check out http://petersteinberger.com/blog/2015/rotation-multiple-windows-bug/ or http://openradar.appspot.com/17265615
- (void)setHidden:(BOOL)hidden
{
  [super setHidden:hidden];

  // Since iOS 8 adding more UIWindow breaks rotation logic
  // Instead of use real hiding, the root view controller needs to be removed.
  if (hidden)
  {
    self.hiddenRootViewController = self.rootViewController;
    [super setRootViewController:nil];
  }
  else
  {
    if (self.hiddenRootViewController)
    {
      [super setRootViewController:self.hiddenRootViewController];
      self.hiddenRootViewController = nil;
    }
  }
}

- (void)setRootViewController:(UIViewController *)rootViewController
{
  if (self.hidden)
  {
    [super setRootViewController:nil];
    self.hiddenRootViewController = rootViewController;
  }
  else
  {
    [super setRootViewController:rootViewController];
    self.hiddenRootViewController = nil;
  }
}

@end
