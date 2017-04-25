//
//  WWSensorMicrophone.h
//  APIObjectiveC
//
//  Created by Saurabh Gupta on 10/10/14.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.
//

#import "WWSensor.h"

/**
 *  The `WWSensorMicrophone` object provides detected sound data from `WWRobot` (read-only).  
 *
 *  `WWRobot` will try to detect sound from a two-dimensional plane and returns the calculated 
 *  amplitude.  If sound is loud enough, `WWRobot` will also triangulate the direction where the 
 *  sound is coming from and return it as triangulationAngle in radians.  If the sound amplitude
 *  is too low to be detected, then triangulationAngle will return WW_ANGLE_UNDEFINED.
 */
@interface WWSensorMicrophone : WWSensor

/**
 *  Amplitude calculated through sound sampling, which reflects the loudness of the sound. Returns values from [WW_VOLUME_MUTE, WW_VOLUME_MAX].
 */
@property (nonatomic, readonly) double amplitude;

/**
 *  Direction angle (in radians) where the sound originates, from the point of view of the robot.  Returns values from [-PI, PI].
 */
@property (nonatomic, readonly) double triangulationAngle;

@end
