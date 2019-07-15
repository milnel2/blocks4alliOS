//
//  WWSensorHistory.h
//  APIObjectiveC
//
//  Created by Kevin Liang on 5/12/14.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.
//

#import "WWsensorSet.h"

/**
 *  The `WWSensorHistory` object contains a set of `WWSensor` objects in reverse chronological order.  New sensor data are coming in
 *  roughly every 30ms under normal conditions.  However, depending on the signal strength of the robot, it may extend out to 40ms.  
 */
@interface WWSensorHistory : WWObject

/**
 *  The number of `WWSensor` objects to store.
 */
@property (nonatomic) NSUInteger limit;

/**
 *  Returns the total count of `WWSensor` objects in this history object.
 *
 *  @return The total count of `WWSensor` objects.
 */
- (NSUInteger) count;

/**
 *  Returns the most recent `WWSensor` object received from `WWRobot`.
 *
 *  CurrentState is updated roughly every 30ms, depending on the signal strength of the robot.
 *
 *  @return Returns the most recent `WWSensor` object.
 */
- (WWSensorSet *) currentState;

/**
 *  Returns the second most recent `WWSensor` object received from `WWRobot`.
 *
 *  @return Returns the second most recent `WWSensor` object.
 */
- (WWSensorSet *) previousState;

/**
 *  Returns the `WWSensor` object specified by index.
 *
 *  If index is out of bounds or no `WWSensor` is associated with the index, then nil is returned.
 *
 *  @param index The index of the desired `WWSensor` object.
 *
 *  @return The associated `WWSensor` object
 */
- (WWSensorSet *) pastStateAtIndex:(NSUInteger)index;

/**
 *  Returns the `WWSensor` object received seconds ago.
 *
 *  The returned `WWSensor` will be the closest `WWSensor` object received at the specified time or sooner.  The `WWSensor` timestamp is used for this calculation. Nil is returned if no corresponding `WWSensor` is found.
 *
 *  @param seconds The specified time ago (in seconds) where `WWSensor` is received.
 *
 *  @return The associated `WWSensor` object.
 */
- (WWSensorSet *) pastStateAtTimeAgo:(double)seconds;

/**
 *  Returns the `WWSensor` object received seconds ago, since the given state.
 *
 *  The returned `WWSensor` will be the closest `WWSensor` object received at the specified time or sooner.  The `WWSensor` timestamp is used for this calculation. Nil is returned if no corresponding `WWSensor` is found or if the state is not in the history list.
 *
 *  @param seconds The specified time (in seconds) where `WWSensor` is received.
 *  @param state The `WWSensor` object from which to count back.
 *
 *  @return The associated `WWSensor` object.
 */
- (WWSensorSet *) pastStateAtTimeAgo:(double)seconds fromState:(WWSensorSet *)state;

@end
