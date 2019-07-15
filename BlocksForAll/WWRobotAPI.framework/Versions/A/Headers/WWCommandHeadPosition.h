//
//  WWCommandHeadPosition.h
//  APIObjectiveC
//
//  Created by Kevin Liang on 3/31/14.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.
//

#import "WWCommand.h"

/**
 *  The `WWCommandHeadPosition` objects sets the `WWRobot` head position horizontally or vertically.
 *
 *  Negative command values represent left (horizontal) or up (vertical). Positive command values
 *  represents right (horizontally) or down (vertically).
 * 
 *  Horizontal head position values have the following valid ranges: -2.094 to 2.094 in radians or -120.0 to 120.0 
 *  in degrees. Vertical head position values have the following ranges: -0.349 to 0.131 in radians or
 *   -20 to 7.5 in degrees.
 */
@interface WWCommandHeadPosition : WWCommand

/**
 *  Specify the position angle for the robot's head, in radians.
 */
@property (nonatomic) double radians;

/**
 *  Initializes the command with specified radians.
 *
 *  @param radians The position in radians.
 *
 *  @return Returns a newly initialized `WWCommandHeadPosition` instance.
 */
- (id) initWithRadians:(double)radians;

/**
 *  Initializes the command with specified degree, which is converted to radians.
 *
 *  @param radians The position in degrees.
 *
 *  @return Returns a newly initialized `WWCommandHeadPosition` instance.
 */
- (id) initWithDegree:(double)degree;

@end
