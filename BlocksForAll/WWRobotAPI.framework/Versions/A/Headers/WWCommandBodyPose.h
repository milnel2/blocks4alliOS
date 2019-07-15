//
//  WWCommandBodyPose.h
//  APIObjectiveC
//
//  Created by Orion Elenzil on 20140912.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.
//

// Coordinate-System:
// Forward           = +X
// Left              = +Y
// Counter-Clockwise = +Theta
//
//         +X  (Forward)
//          ^
//          |         <-
//          |            \
// +Y <-----*     +Theta |
// (Left)                /
//
// There are two ways of controlling path-following;
// "Global" means the parameters are interpreted in the Global Coordinate Frame.
// "Relative_Command" means the parameters are interpreted relative to the previous command.
// "Relative_Measured" means the parameters are interpreted relative to the measured position of the robot.
// The Global reference frame can be reset by sending initWithSetGlobalX() with all parameters equal to zero.
//
// For example, if you have 100 poses relative to whereever the robot is right now,
// just issue initWithSetGlobalX:0 Y:0 Theta:0 Time:0
// and then issue all the 100 poses with initWithGlobalX:Y:Theta:Time.
//
// time is relative to when the command is received by the robot.
//
// direction indicates whether the robot should use forward motion to achieve the next pose, backward, or whether it should decide for itself.
// default is WW_POSE_DIRECTION_FORWARD.
//
// wrapTheta tells the robot whether it should consider 0º to be the same as 360º. WW_POSE_WRAP_ON indicates that they should be considered the same.
// default is WW_POSE_WRAP_OFF.


#import "WWCommand.h"

@interface WWCommandBodyPose : WWCommand

@property (nonatomic) double x;
@property (nonatomic) double y;
@property (nonatomic) double radians;
@property (nonatomic) double time;
@property (nonatomic) WWPoseMode mode;
@property (nonatomic) WWPoseDirection direction;
@property (nonatomic) WWPoseWrap wrapTheta;

- (id) initWithX:(double)x Y:(double)y Radians:(double)radians Time:(double)time Mode:(WWPoseMode)mode;
- (id) initWithGlobalX:(double)x Y:(double)y Radians:(double)radians Time:(double)time;
- (id) initWithRelativeCommandX:(double)x Y:(double)y Radians:(double)radians Time:(double)time;
- (id) initWithRelativeMeasuredX:(double)x Y:(double)y Radians:(double)radians Time:(double)time;
- (id) initWithSetGlobalX:(double)x Y:(double)y Radians:(double)radians Time:(double)time;

@end
