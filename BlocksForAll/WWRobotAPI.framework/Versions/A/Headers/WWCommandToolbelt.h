//
//  WWCommandToolbelt.h
//  APIObjectiveC
//
//  Created by Kevin Liang on 5/15/14.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.
//

#include "WWContentDefinitions.h"

@class WWCommandSet, WWCommandSetSequence;

/**
 *  Convenience class to generate `WWCommandSet`.
 */
@interface WWCommandToolbelt : NSObject

/**
 *  Resets the robot to its original state after power on.
 *
 * @return `WWCommandSet` instance.
 */
+ (WWCommandSet *) defaultState;

/**---------------------------------------------------------------------------------------
 *  @name Robot movement
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Initializes a `WWCommandSet` object that stops all `WWRobot` movement.
 *
 *  @return a `WWCommandSet` instance.
 */
+ (WWCommandSet *) moveStop;



/**---------------------------------------------------------------------------------------
 *  @name Robot eyes
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Initializes a `WWCommandSet` object that runs a specific eye animation on a `WWRobot`.
 *
 *  @return a `WWCommandSet` instance.
 */
+ (WWCommandSet *) eyeAnimation:(NSString *)animationName;

/**
 *  Initializes a `WWCommandSet` object that turns all the lights on with specific brightness on a `WWRobot`.
 *
 *  @return a `WWCommandSet` instance.
 */
+ (WWCommandSet *) eyeAllLightsOnWithBrightness:(double)brightness;


/**---------------------------------------------------------------------------------------
 *  @name Robot lights
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Initializes a `WWCommandSet` object that turns off all lights for a `WWRobot`.
 *
 *  @return a `WWCommandSet` instance.
 */
+ (WWCommandSet *) lightsOff;



/**---------------------------------------------------------------------------------------
 *  @name Robot sounds
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Initializes a `WWCommandSet` object that stops the current sound for a `WWRobot`.
 *
 *  @return a `WWCommandSet` instance.
 */
+ (WWCommandSet *) stopSound;



/**---------------------------------------------------------------------------------------
 *  @name Robot head positions
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Initializes a `WWCommandSet` object that centers the head position for a `WWRobot`.
 *
 *  @return a `WWCommandSet` instance.
 */
+ (WWCommandSet *) headStraight;



/**---------------------------------------------------------------------------------------
 *  @name Ball launcher
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Initializes a `WWCommandSet` object that triggers a ball reload action (from left side) for a `WWRobot`.
 *
 *  @return a `WWCommandSet` instance.
 */
+ (WWCommandSet *) launcherReloadLeft;

/**
 *  Initializes a `WWCommandSet` object that triggers a ball reload action (from right side) for a `WWRobot`.
 *
 *  @return a `WWCommandSet` instance.
 */
+ (WWCommandSet *) launcherReloadRight;

/**
 *  Initializes a `WWCommandSet` object that triggers a ball launch action for a `WWRobot`.
 *
 *  @param power internal power which to strike the launcher, range [WW_LAUNCHER_POWER_MIN - WW_LAUNCHER_POWER_MAX]
 *
 *  @return a `WWCommandSetSequence` instance.
 */
+ (WWCommandSet *) launcherFlingWithPower:(double)power;



@end
