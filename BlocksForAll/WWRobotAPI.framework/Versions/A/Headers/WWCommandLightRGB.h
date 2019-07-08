//
//  WWCommandLightRGB.h
//  APIObjectiveC
//
//  Created by Kevin Liang on 3/31/14.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.
//

#import "WWCommand.h"

/**
 *  The `WWCommandLightRGB` object instructs a `WWRobot` how to set the RGB values of its light.
 *  This command is applicable for light components capable of expressing the full RGB color range.
 *
 *  For each of the RGB values, the value is normalized between [WW_LIGHT_BRIGHTNESS_MIN, WW_LIGHT_BRIGHTNESS_MAX].
 */
@interface WWCommandLightRGB : WWCommand

/**
 *  The normalized red value of the light, between [WW_LIGHT_BRIGHTNESS_MIN, WW_LIGHT_BRIGHTNESS_MAX].
 */

@property (nonatomic) double red;

/**
 *  The normalized green value of the light, between [WW_LIGHT_BRIGHTNESS_MIN, WW_LIGHT_BRIGHTNESS_MAX].
 */
@property (nonatomic) double green;

/**
 *  The normalized blue value of the light, between [WW_LIGHT_BRIGHTNESS_MIN, WW_LIGHT_BRIGHTNESS_MAX].
 */
@property (nonatomic) double blue;

/**
 *  Initializes the command with specified red, green, and blue values.
 *
 *  @param red The normalized red value (between [WW_LIGHT_BRIGHTNESS_MIN, WW_LIGHT_BRIGHTNESS_MAX]).
 *  @param green The normalized green value (between [WW_LIGHT_BRIGHTNESS_MIN, WW_LIGHT_BRIGHTNESS_MAX]).
 *  @param blue The normalized blue value (between [WW_LIGHT_BRIGHTNESS_MIN, WW_LIGHT_BRIGHTNESS_MAX]).
 *
 *  @return Returns a newly initialized `WWCommandLightRGB` instance.
 */
- (id) initWithRed:(double)red green:(double)green blue:(double)blue;

@end
