//
//  WWSensorAccelerometer.h
//  APIObjectiveC
//
//  Created by Kevin Liang on 3/31/14.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.

#import "WWSensor.h"

/**
 *  The `WWSensorAccelerometer` object provides acceleration-related data from `WWRobot`.  
 *  As the robot moves, its hardware reports linear acceleration changes along the primary axes in
 *  three-dimensional space.  
 *
 *  This is a read-only data from `WWRobot`, and the axis uses the "right-hand" coordinate system space, 
 *  where axis values are represented as:
 *  X-axis (index finger) => "forward" (positive), "backward" (negative)
 *  Y-axis (middle finger) => "left" (positive), "right" (negative)
 *  Z-axis (thumb) => "up" (positive), "down" (negative).
 */
@interface WWSensorAccelerometer : WWSensor

/**
 *  Returns the X-axis value.
 */
@property (nonatomic, readonly) double x;

/**
 *  Returns the Y-axis value.
 */
@property (nonatomic, readonly) double y;

/**
 *  Returns the Z-axis value.
 */
@property (nonatomic, readonly) double z;

@end
