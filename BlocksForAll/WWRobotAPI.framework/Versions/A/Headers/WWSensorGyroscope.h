//
//  WWSensorGyroscope.h
//  APIObjectiveC
//
//  Created by Kevin Liang on 3/31/14.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.
//
// Coordinate system:
// Using the thumb, index, and middle fingers of your RIGHT hand as a coordinate system,
// X-axis = index finger  = "forward"
// Y-axis = middle finger = "left"
// Z-axis = thumb         = "up"
// For rotation, again use a right-handed system, in which you make a fist but with your thumb stuck out.
// With the thumb aligned to the axis in question, the direction of curl of the other fingers is positive rotation.
// For for example, rotation about X such that the Y axis becomes the Z axis is positive rotation about X, aka Roll.

#import "WWSensor.h"

/**
 *  The `WWSensorGyroscope` object provides gyroscope-related data from `WWRobot`.
 *  As the robot moves, its hardware reports angular changes around the primary axes in
 *  three-dimensional space.
 *  These are reported in Radians Per Second.
 *
 *  This is read-only data from `WWRobot`, and the axis uses the "right-hand" coordinate system space,
 *  where axis values are represented as:
 *  X-axis (index finger) => "forward" (positive), "backward" (negative)
 *  Y-axis (middle finger) => "left" (positive), "right" (negative)
 *  Z-axis (thumb) => "up" (positive), "down" (negative)
 *
 *  For convenience, we also provide "airplane" coordinate system space information, where axis values
 *  are represented as:
 *  Roll = X-axis
 *  Pitch = Y-axis
 *  Yaw = Z-axis
 */
@interface WWSensorGyroscope : WWSensor

@property (nonatomic, readonly) double x;
@property (nonatomic, readonly) double y;
@property (nonatomic, readonly) double z;

@property (nonatomic, readonly) double roll;
@property (nonatomic, readonly) double pitch;
@property (nonatomic, readonly) double yaw;

@end
