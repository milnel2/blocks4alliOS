//
//  WWCommandSet.h
//  APIObjectiveC
//
//  Created by Kevin Liang on 3/31/14.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.

//

#import "WWConstants.h"
#import "WWComponentSet.h"

@class WWCommand, WWCommandHeadPosition, WWCommandLightRGB, WWCommandEyeRing, WWCommandLightMono, WWCommandSpeaker, WWCommandHeadBang, WWCommandBodyLinearAngular, WWCommandBodyWheels, WWCommandLauncherFling, WWCommandLauncherReload, WWCommandBodyPose;

/**
 *  `WWCommandSet` is a subclass of `WWComponentSet` with strict type-checking and convenience
 *  methods to handle `WWCommand` objects.
 */
@interface WWCommandSet : WWComponentSet

/**---------------------------------------------------------------------------------------
 *  @name Adding commands
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Inserts a given `WWCommandBodyWheels` object to the set, overwriting an existing mapping if it exists.
 *
 *  @param wheels The `WWCommandBodyWheels` object that specifies the wheel velocities.
 */
- (void) setBodyWheels:(WWCommandBodyWheels *)wheels;

/**
 *  Inserts a given `WWCommandBodyLinearAngular` object to the set, overwriting an existing mapping if it exists.
 *
 *  @param bodyLinAng The `WWCommandBodyLinearAngular` object that specifies the body's linear/angular velocities.
 */
- (void) setBodyLinearAngular:(WWCommandBodyLinearAngular *)bodyLinAng;

/**
 *  Inserts a given `WWCommandHeadPosition` object to the set, overwriting an existing mapping if it exists.
 *
 *  @param tilt The `WWCommandHeadPosition` object that specifies the head tilt position.
 */
- (void) setHeadPositionTilt:(WWCommandHeadPosition *)tilt;

/**
 *  Inserts a given `WWCommandHeadPosition` object to the set, overwriting an existing mapping if it exists.
 *
 *  @param pan The `WWCommandHeadPosition` object that specifies the head tilt position.
 */
- (void) setHeadPositionPan:(WWCommandHeadPosition *)pan;

/**
 *  Inserts a given `WWCommandEyeRing` object to the set, overwriting an existing mapping if it exists.
 *
 *  @param eye The `WWCommandEyeRing` object that specifies the eye values.
 */
- (void) setEyeRing:(WWCommandEyeRing *)eye;

/**
 *  Inserts a given `WWCommandLightRGB` object to the set, overwriting an existing mapping if it exists.
 *
 *  @param eye The `WWCommandLightRGB` object that specifies the eye color.
 */
- (void) setEyeLight:(WWCommandLightRGB *)eye;

/**
 *  Inserts a given `WWCommandLightRGB` object to the set, overwriting an existing mapping if it exists.
 *
 *  @param leftEar The `WWCommandLightRGB` object that specifies the left ear color.
 */
- (void) setLeftEarLight:(WWCommandLightRGB *)leftEar;

/**
 *  Inserts a given `WWCommandLightRGB` object to the set, overwriting an existing mapping if it exists.
 *
 *  @param rightEar The `WWCommandLightRGB` object that specifies the right ear color.
 */
- (void) setRightEarLight:(WWCommandLightRGB *)rightEar;

/**
 *  Inserts a given `WWCommandLightRGB` object to the set, overwriting an existing mapping if it exists.
 *
 *  @param chest The `WWCommandLightRGB` object that specifies the chest color.
 */
- (void) setChestLight:(WWCommandLightRGB *)chest;

/**
 *  Insert a given `WWCommandLightMono` object to the set, overwriting an existing mapping if it exists.
 *
 *  @param mainButton The `WWCommandLightMono` object that specifies the mainButton brightness.
 */
- (void) setMainButtonLight:(WWCommandLightMono *)mainButton;



/**
 TODO: add description for this method
 */
- (void) setBodyPose:(WWCommandBodyPose *)bodyPose;


/**
 *  Inserts a given `WWCommandLightMono` object to the set, overwriting an existing mapping if it exists.
 *
 *  @param tail The `WWCommandLightMono` object that specifies the tail light brightness.
 */
- (void) setTailLight:(WWCommandLightMono *)tail;

/**
 *  Inserts a given `WWCommandSpeaker` object to the set, overwriting an existing mapping if it exists.
 *
 *  @param sound The `WWCommandSpeaker` object that specifies the sound to play.
 */
- (void) setSound:(WWCommandSpeaker *)sound;

/**
 *  Inserts a given `WWCommandHeadBang` object to the set, overwriting an existing mapping if it exists.
 *
 *  @param bang The `WWCommandHeadBang` object that allows our robot to nod quickly (used for xylophone note strike).
 */
- (void) setHeadBang:(WWCommandHeadBang *)bang;

/**
 *  Inserts a given `WWCommand` object to the set, overwriting an existing mapping if it exists.
 *
 *  @param command The `WWCommand` object to insert into the set.
 *  @param key The mapping index (NSNumber representation of WWComponentId).
 */
- (void) setCommand:(WWCommand *)command forKey:(id)key;

/**
 *  Inserts necessary `WWCommand` objects to set wheel velocities to the desired speeds.
 *
 *  @param wheels The desired speed (in cm/s).
 */
- (void) setMotorsAllToSpeed:(double)speed;

/**
 *  Inserts the given `WWCommandHeadPosition` objects to the set, overwriting an existing mapping if it exists.
 *
 *  @param tilt The `WWCommandHeadPosition` object that specifies the head tilt position.
 *  @param pan The `WWCommandHeadPosition` object that specifies the head pan position.
 */
- (void) setHeadPositionTilt:(WWCommandHeadPosition *)tilt pan:(WWCommandHeadPosition *)pan;

/**
 *  Inserts a given `WWCommandLightRGB` object to the set, overwriting an existing mapping if it exists.
 *
 *  @param leftEar The `WWCommandLightRGB` object that specifies the left ear color.
 *  @param rightEar The `WWCommandLightRGB` object that specifies the right ear color.
 */
- (void) setEarLightLeft:(WWCommandLightRGB *)leftEar right:(WWCommandLightRGB *)rightEar;

/**
 *  Inserts a given `WWCommandLauncherFling` object to the set, overwriting an existing mapping if it exists.
 *
 *  @param fling The `WWCommandLauncherFling` object that specifies the how hard to fling the ball.  Must have ball launcher accessory!
 */
- (void) setLauncherFling:(WWCommandLauncherFling *)fling;

/**
 *  Inserts a given `WWCommandLauncherReload` object to the set, overwriting an existing mapping if it exists.
 *
 *  @param fling The `WWCommandLauncherReload` object that specifies which ball to reload from.  Must have ball launcher accessory!
 */
- (void) setLauncherReload:(WWCommandLauncherReload *)reload;

/**---------------------------------------------------------------------------------------
 *  @name Querying command set
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Returns the `WWCommand` object associated with the given WWComponentId.
 *
 *  If the mapping does not exist, null is returned.
 *
 *  @param index The WWComponentId mapping for the desired command.
 *
 *  @return The associated `WWCommand` object in the mapping.
 */
- (WWCommand *) commandForIndex:(WWComponentId)index;


/**---------------------------------------------------------------------------------------
 *  @name Removing commands
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Removes the `WWCommand` object associated with the given WWComponentId.
 *
 *  If desired mapping doesn't exist, this method is a no-op.
 *
 *  @param index The WWComponentId mapping for the desired command.
 */
- (void) removeCommandForIndex:(WWComponentId)index;


/**---------------------------------------------------------------------------------------
 *  @name Convenience operations
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Convenience method that calls mergeSet:withSet method in `WWComponentSet` with
 *  the right parameter checking.
 *
 *  @param firstSet  The first `WWCommandSet` object to merge.
 *  @param secondSet The second `WWCommandSet` object to merge.
 *
 *  @return A initialized `WWCommandSet` instance with merged results of firstSet and secondSet.
 */
+ (WWCommandSet *) mergeSet:(WWCommandSet *)firstSet withSet:(WWCommandSet *)secondSet;


@end
