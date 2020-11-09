//
//  WWCommandBodyWheels.h
//  APIObjectiveC
//
//  Created by Kevin Liang on 11/10/14.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.
//

#import "WWCommand.h"

/**
 *  `WWCommandBodyWheels` objects instruct a `WWRobot` how to move by specifying the velocity for each
 *   wheel.
 *
 *  Valid wheel velocity values range from -100 to 100 cm/s.  However, actual speed
 *  might vary based on surface conditions (e.g., carpet speed will be slower).
 */
@interface WWCommandBodyWheels : WWCommand

/**
 *  Specify the left wheel velocity (in cm/s):
 */
@property (nonatomic) double leftWheelVelocity;

/**
 *  Specify the right wheel velocity (in cm/s):
 */
@property (nonatomic) double rightWheelVelocity;

/**
 *  Initializes the command with specified left and right wheel velocity.
 *
 *  @param leftVelocity  The left wheel velocity (in cm/s).
 *  @param rightVelocity The right wheel velocity (in cm/s).
 *
 *  @return Returns a newly initialized `WWComandBodyWheels` instance.
 */
- (id) initWithLeftWheel:(double)leftVelocity rightWheel:(double)rightVelocity;

@end
