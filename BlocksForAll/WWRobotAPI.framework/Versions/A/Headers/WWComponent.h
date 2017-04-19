//
//  WWComponent.h
//  APIObjectiveC
//
//  Created by Kevin Liang on 3/26/14.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.
//

// Nomenclature:
// WWCommand represents a single command sent to a robot.
//   note that some commands negate the effect of previous commands, eg WheelSpeed vs BodyMotion.
//   eg: "Set Left Wheel Speed to 30 and Right Wheel Speed to -20"
//   eg: "Set body linear velocity to 40"
// WWSensor represents a single sensor data from the robot.
//   note that some sensors are synthetic, meaning they don't come from a simple physical detector.
//   some of them are synthesized on the robot, and some in the API.
// WWComponent is either a sensor or a command.
// WWCommandSet is a collection of WWCommands.
// WWSensorSet is a collection of WWSensors.

#import "WWObject.h"

/**
 *  `WWComponent` is the parent class of `WWCommand` and `WWSensor`, because both of these classes are treated similarly
 *  by `WWRobot` class.  Furthermore, this class provides known method signatures to be overwritten by child classes
 *  to standardize on the treatment of `WWCommand` and `WWSensor`.
 */
@interface WWComponent : WWObject

/**---------------------------------------------------------------------------------------
 *  @name Over-written by child classes
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Returns whether the associated values have the right boundaries.
 *
 *  @return Returns true if values are valid, false otherwise.
 */
- (BOOL) hasValidValues;

/**
 *  Returns whether this component has the same semantic values as otherComponent.
 *
 *  This only returns true if ALL values are the same (as determined per each class).
 *
 *  @param otherComponent The component with which to compare.
 *
 *  @return Returns true if all values are the same, false otherwise.
 */
- (BOOL) hasSameValues:(WWComponent *)otherComponent;

@end
