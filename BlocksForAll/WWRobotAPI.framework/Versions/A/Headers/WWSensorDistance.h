//
//  WWSensorDistance.h
//  APIObjectiveC
//
//  Created by Kevin Liang on 3/31/14.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.
//

#import "WWSensor.h"

/**
 *  The `WWSensorDistance` object provides estimated distance data from `WWRobot` (read-only).  
 *
 *  Reflectance data is returned as the raw data to calculate distance from.  Reflectance value is based 
 *  on the light reading of the IR sensors on the robot, so calculating the actual distance from this data 
 *  will be heavily based on the environment visibility (e.g. dark vs. incandescent light) and object's 
 *  reflectivity (e.g. white vs. black).
 */
@interface WWSensorDistance : WWSensor

/**
 *  Returns the averaged light reflectance received by the sensor.
 */
@property (nonatomic, readonly) double reflectance;

@end
