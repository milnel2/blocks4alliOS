//
//  WWEventDataSource.h
//  APIObjectiveC
//
//  Created by Kevin Liang on 3/31/14.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.
//

#import "WWObject.h"

@class WWEvent;

/**
 *  The `WWEventDataSource` object contains a set of `WWEvent` objects and convenience
 *  methods to operate on these objects.
 */
@interface WWEventDataSource : WWObject

/**---------------------------------------------------------------------------------------
 *  @name Add events
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Inserts the given `WWEvent` to the datasource.
 *
 *  If given event is already in the data source (using isEqual: comparator), then this operation is a no-op.
 *
 *  @param event The event object to be inserted.
 */
- (void) addEvent:(WWEvent *)event;


/**---------------------------------------------------------------------------------------
 *  @name Remove events
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Removes the given `WWEvent` from the datasource. 
 * 
 *  If given event is not in the data source (using isEqual: comparator), then this operation is a no-op.
 *
 *  @param event The event object to be removed.
 */
- (void) removeEvent:(WWEvent *)event;

/**
 *  Removes all of the existing events from the datasource.
 *
 *  If this datasource is already empty, the operation is a no-op.
 */
- (void) removeAllEvents;

/**
 *  Removes all matched `WWEvent` from datasource.
 *
 *  Idnetifier will be matched by using the hasIdentifier method in `WWEvent`.
 *
 *  @param identifier The identifier string to be matched.
 */
- (void) removeEventWithIdentifier:(NSString *)identifier;


/**---------------------------------------------------------------------------------------
 *  @name Querying command set
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Determines whether the given `WWEvent` is in this datasource.
 *
 *  Matching is determined by the event's isEqual: comparator.
 *
 *  @param event The event to be queried.
 *
 *  @return True if event is in the datasource, false otherwise.
 */
- (BOOL) containsEvent:(WWEvent *)event;

/**
 *  Returns the total count of all `WWEvent` objects in this datasource.
 *
 *  @return The total count of all `WWEvent` objects.
 */
- (NSUInteger) count;

/**
 *  Returns a shallow copy of all the `WWEvent` objects in this datasource.
 *
 *  @return The array of all `WWEvent` objects.
 */
- (NSArray *) allEvents;

@end
