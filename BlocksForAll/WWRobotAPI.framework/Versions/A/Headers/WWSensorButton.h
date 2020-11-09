//
//  WWSensorButton.h
//  APIObjectiveC
//
//  Created by Kevin Liang on 3/31/14.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.
//

#import "WWSensor.h"

/**
 *  The `WWSensorButton` object provides button state from `WWRobot` (read-only).
 */
@interface WWSensorButton : WWSensor

/**
 *  Returns whether the specific button is being pressed.
 */
@property (nonatomic, readonly) BOOL isPressed;

@end
