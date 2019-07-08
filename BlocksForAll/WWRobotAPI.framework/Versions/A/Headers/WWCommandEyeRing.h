//
//  WWCommandEyeRing.h
//  APIObjectiveC
//
//  Created by Kevin Liang on 3/31/14.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.
//

#import "WWCommand.h"

/**
 *  `WWCommandEyeRing` objects instruct a `WWRobot` how to display its eye pattern.  
 *
 *  For ledBitmap, the mapping represents an analog clock, where index 0 represents the light at 12 o'clock, 
 *  index 1 represents the light at 1 o'clock, index 2 represents the light at 2 o'clock, and so on.
 */
@interface WWCommandEyeRing : WWCommand

/**
 *  The filename for the default eye animations to play.
 */
@property (nonatomic, strong) NSString *animationFile;

/**
 *  The normalized brightness value of the light, between [WW_LIGHT_BRIGHTNESS_MIN, WW_LIGHT_BRIGHTNESS_MAX].
 */
@property (nonatomic) double brightness;

/**
 *  The eye bitmap pattern to display, represented as an array of booleans.
 */
@property (nonatomic, strong) NSArray *ledBitmap;

/**
 *  Initializes the command with specific eye animation.
 *
 *  @param animationFile The filename of the eye animation.
 *
 *  @return Returns a newly initialized `WWCommandEyeRing` instance.
 */
- (id) initWithAnimation:(NSString *)animationFile;

/**
 *  Initializes the command with a specific eye bitmap pattern.
 *
 *  @param bitmap The bitmap pattern represented as array of booleans.
 *
 *  @return Returns a newly initialized `WWCommandEyeRing` instance.
 */
- (id) initWithBitmap:(NSArray *)bitmap;

/**
 *  Sets the index of the ledBitmap to the specified value.
 *
 *  @param on    The boolean value that specifies whether the light is on.
 *  @param index The index of the light position.
 */
- (void) setLEDValue:(BOOL)on atIndex:(NSUInteger)index;

/**
 *  Returns the led value at the specified index.
 *
 *  If index is out of bound (index >= ledCount), this method returns false.
 *
 *  @param index The index of the light position.
 *
 *  @return The boolean value that specifies whether the light is on.
 */
- (BOOL) LEDValueAtIndex:(NSUInteger)index;

/**
 *  Convenience method that sets all the lights to the specified value.
 *
 *  @param on The boolean value that specifies if the light should be on.
 */
- (void) setAllBitmap:(BOOL)on;

@end
