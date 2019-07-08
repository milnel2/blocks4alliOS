//
//  WWSensorEncoder.h
//  APIObjectiveC
//
//  Created by Orion Elenzil on 9/11/2014.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.
//

#import "WWSensor.h"

/**
 *  The `WWSensorEncoder` object returns the net distance for wheel revolutions from `WWRobot` (read-only).
 *
 *  Distance tracking starts at the initialization of the `WWRobot` object (on robot discovery),
 *  increments as robot moves forward, and decrements as the robot moves backward.  
 *
 *  Theoretically, distance tracking is accurate. However, due to wheel slip, the reflected distance will have 
 *  some margin of error.
 */
@interface WWSensorEncoder : WWSensor

/**
 *  Returns the calculated distance (in CM).
 */
@property (nonatomic, readonly) double distance;

@end
