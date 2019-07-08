//
//  WWComponentSet.h
//  APIObjectiveC
//
//  Created by Kevin Liang on 3/26/14.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.
//

#import "WWComponent.h"

/**
 *  The `WWComponentSet` object contains an unique [WWComponentId => `WWComponent`] mapping set,
 *  where uniqueness is determined by the mapping, and not the `WWComponent` object itself.  
 *  
 *  This is the parent class of `WWCommandSet` and `WWSensorSet` objects as they behave similarly.
 */
@interface WWComponentSet : WWObject

/**---------------------------------------------------------------------------------------
 *  @name Deriving new sets
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Initializes a shallow copy of the `WWComponentSet`.
 *
 *  @return Returns a shallow copy of the `WWComponentSet` instance.
 */
- (WWComponentSet *)cloneCopy;

/**
 *  Initializes a new `WWComponentSet` object that contains the superset of firstSet and
 *  secondSet's WWComponentId => `WWComponent` mapping.
 *
 *  If both the firstSet and secondSet object have the same mapping (e.g. WW_COMMAND_LIGHT_RGB_LEFT_EAR
 *  => WWCommandLightRGBObject1 for firstSet, WW_COMMAND_LIGHT_RGB_LEFT_EAR => WWCommandLightRGBObject2 
 *  for secondSet), then the resulting merged set object always takes the mapping from
 *  secondSet object (e.g. WW_COMMAND_LIGHT_RGB_LEFT_EAR => WWCommandLightRGBObject2).
 *  If either of the set objects are null or empty, a shallow copy of the non-null object is returned,
 *  which is equaivalent to invoking cloneCopy method on the non-empty set object.
 *
 *  @param firstSet  The first `WWComponentSet` object to merge.
 *  @param secondSet The second `WWComponentSet` object to merge.
 *
 *  @return Returns a newly initialized `WWComponentSet` instance with merged mapping.
 */
+ (WWComponentSet *) mergeSet:(WWComponentSet *)firstSet withSet:(WWComponentSet *)secondSet;


/**---------------------------------------------------------------------------------------
 *  @name Comparing sets
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Determines if this set object is a subset of the otherSet object.
 *
 *  Subset is determined if this set's mapping of WWComponentId => `WWComponent` is a subset of the
 *  otherSet's WWComponentId => `WWComponent` mapping.  The actual values within `WWComponent` object
 *  can be different.  If this object has an empty mapping set, it is determined to be a subset of the
 *  otherSet.
 *
 *  @param otherSet The other `WWComponentSet` object with which to compare.
 *
 *  @return Returns true if subset, false otherwise.
 */
- (BOOL) isSubsetOf:(WWComponentSet *)otherSet;

/**
 *  Determines if this set object has the same `WWComponent` mapping as the otherSet object.
 *
 *  Equality is determined if this set's mapping of WWComponentId => `WWComponent` is the exact same mapping
 *  as the otherSet object.  The actual values within `WWComponent` object can be different.
 *  If both set objects are empty, this method returns true.
 *
 *  @param otherSet The other `WWComponentSet` object with which to compare.
 *
 *  @return Returns true if equal, false otherwise.
 */
- (BOOL) isEqualTo:(WWComponentSet *)otherSet;


/**---------------------------------------------------------------------------------------
 *  @name Modifying a set
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Adds the WWComponentId => `WWComponent` mapping from the otherSet object to this set object.
 *
 *  If otherSet object has the same mapping as this set object, the otherSet's mapping
 *  will OVERWRITE this set's mapping.
 *
 *  @param otherSet The other`WWComponentSet` object to copy from.
 */
- (void) copyFromSet:(WWComponentSet *)otherSet;


/**---------------------------------------------------------------------------------------
 *  @name Querying a set
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Whether the set is empty.
 *
 *  @return Returns true if set has 0 mapping, false otherwise.
 */
- (BOOL) empty;

/**
 *  A new array containing the set's keys or empty array if set has no mappings (read-only).
 *
 *  @return Array of NSNumber representation of WWComponentIds
 */
- (NSArray *)allKeys;

/**
 *  The number of mappings in the set (read-only).
 *
 *  @return Total count of mappings.
 */
- (NSUInteger) count;

@end
