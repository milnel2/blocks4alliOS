//
//  WWSensorHeadPosition.h
//  APIObjectiveC
//
//  Created by Kevin Liang on 9/15/14.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.
//

#import "WWSensor.h"

/**
 *  The `WWSensorHeadPosition` object provides the current head position for `WWRobot` (read-only).
 *
 *
 *  Negative sensor values Sensor values represent left (horizontal) or up (vertical).
 *  Positive values represent right (horizontal) or down (vertical).
 *
 *  Horizontal head position values have the following valid ranges: -2.338 to 2.338 in radians or -135.0 to 135.0
 *  in degrees. Vertical head position values have the following ranges: -0.436 to 0.183 in radians or
 *   -25 to 10.5 in degrees.
 */
@interface WWSensorHeadPosition : WWSensor

/**
 *  Returns the angle of the current head position (in radians).
 */
@property (nonatomic, readonly) double radians;

/**
 *  Returns the angle of the current head position (in degrees).
 */
@property (nonatomic, readonly) double degrees;

@end
