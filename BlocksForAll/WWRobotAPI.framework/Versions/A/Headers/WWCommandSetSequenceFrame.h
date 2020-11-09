//
//  WWCommandSetSequenceFrame.h
//  APIObjectiveC
//
//  Created by Kevin Liang on 4/7/14.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.
//

#import "WWObject.h"

@class WWCommandSet;

/**
 *  The `WWCommandSetSequenceFrame` object is a container for a single `WWCommandSet` object and its execution time (in seconds).
 *  This class is used in conjunction with the `WWCommandSetSequence` class to represent serial, ordered execution for WonderWorkshop robots.
 */
@interface WWCommandSetSequenceFrame : WWObject

/**
 *  Returns an initialized `WWCommandSetSequenceFrame` object with the corresponding `WWCommandSet` and duration.
 *
 *  @param commandSet The `WWCommandSet` object associated in this frame.
 *  @param duration   The duration of the `WWCommandSet` execution, in seconds.
 *
 *  @return A `WWCommandSetSequenceFrame` object.
 */

+ (WWCommandSetSequenceFrame *) frameWithCommandSet:(WWCommandSet *)commandSet duration:(double)duration;

/**
 *  The corresponding `WWCommandSet` object to execute during this frame.
 */
@property (nonatomic, strong) WWCommandSet *commandSet;

/**
 *  The execution time of this frame, in seconds.
 */
@property (nonatomic) double duration;

@end
