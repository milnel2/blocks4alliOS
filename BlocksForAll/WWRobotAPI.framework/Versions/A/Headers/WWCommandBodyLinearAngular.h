//
//  WWCommandBodyLinearAngular.h
//  APIObjectiveC
//
//  Created by Saurabh Gupta on 7/30/14.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.
//

#import "WWCommand.h"

/**
 *  `WWCommandBodyLinearAngular` objects instruct a `WWRobot` how to position its body
 *  in terms of linear and angular velocity, assuming that the center point is the center point of the
 *  robot.
 *
 *  Valid linear velocity values range from -100 to 100 cm/s and angular velocity values range from -8 to 8 radians/s.
 *  Wonder Workshop robots prioritize angular precision over linear precision, which helps them drive straight. So, if
 *  the command expressed max linear (100cm/s) and max angular (8rad/s) velocity, the robot will likely spin
 *  in place to achieve desired angular velocity, rather than move forward.  
 *
 *  Note: The actual speed will vary based on surface conditions (e.g., carpet speed will be slower).
 *
 * | Linear (cm/s) | Angular (radians/s) | Result                                                                                                       |
 * |---------------|---------------------|-------                                                                                                       |
 * | 50            | 0                   | Go straight forward at .5 meters per second.                                                                 |
 * | 0             | 3.14159             | Turn in-place counter-clockwise at 1/2 a revolution per second.                                              |
 * | 50            | 3.14159             | Drive in a counter-clockwise circle with circumference of one meter, taking two seconds to complete one lap. |
 *
 */
@interface WWCommandBodyLinearAngular : WWCommand

/**
 *  Specify the linear velocity (in cm/s) for this command.
 */
@property (nonatomic) double linearVelocity;

/**
 *  Specify the angular velocity (in radian/s) for this command.
 */
@property (nonatomic) double angularVelocity;

/**
 *  Specify the linear acceleration magnitude (in cm/s^2) for this command.
 *  The magnitude must be positive. If it's set to negative, it will be flipped.
 */
@property (nonatomic) double linearAccelerationMagnitude;

/**
 *  Specify the angular acceleration magnitude (in radian/s^2) for this command.
 *  The magnitude must be positive. If it's set to negative, it will be flipped.
 */
@property (nonatomic) double angularAccelerationMagnitude;

/**
 *  For the flavour without acceleration, whether or not to use a different BT command,
 *  which is implemented on-robot via Pose commands.
 */
@property (nonatomic) BOOL usePose;


/**
 *  Initialize the command with specified linear and angular velocity.
 *
 *  @param linear  The linear velocity in cm/s.
 *  @param angular The angular velocity in radian/s.
 *
 *  @return Returns a newly initialized `WWCommandBodyLinearAngular`.
 */
- (id) initWithLinear:(double)linear angular:(double)angular;

/**
 *  Initialize the command with specified linear and angular velocity and whether to use pose.
 *
 *  @param linear  The linear velocity in cm/s.
 *  @param angular The angular velocity in radian/s.
 *  @param usePose Whether to use the pose-based version.
 *
 *  @return Returns a newly initialized `WWCommandBodyLinearAngular`.
 */
- (id) initWithLinear:(double)linear angular:(double)angular usePose:(BOOL)usePose;


/**
 *  Initialize the command with specified target linear, angular velocity and linear, angular acceleration.
 *
 *  @param linear                       The target linear velocity in cm/s.
 *  @param angular                      The target angular velocity in radian/s.
 *  @param linearAccelerationMagnitude  The linear acceleration magnitude in cm/s^2.
 *  @param acgularAccelerationMagnitude The angular acceleration magnitude in radian/s^2.
 *
 *  @return Returns a newly initialized `WWCommandBodyLinearAngular`.
 *  
 *  NOTE: If the acceleration magnitude is set to 0, the robot will stay in the current velocity.
 *        Acceleration magnitude should be non-negative. So the developer don't need to worry about if the
 *        acceleration should be positive or negative. The robot will decide according to the current velocity
 *        and target velocity.
 */
- (id) initWithLinear:(double)linearVel angular:(double)angularVel
   linearAccelerationMagnitude: (double)linearAccMag angularAccelerationMagnitude: (double) angularAccMag;

@end
