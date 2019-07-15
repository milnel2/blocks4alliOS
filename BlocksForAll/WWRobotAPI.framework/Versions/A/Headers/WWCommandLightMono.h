//
//  WWCommandLightMono.h
//  APIObjectiveC
//
//  Created by Kevin Liang on 3/31/14.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.
//

#import "WWCommand.h"

/**
 *  The `WWCommandLightMono` object instructs a `WWRobot` how to set the brightness of a light.
 *  This command is applicable for light components with brightness values rather instead of the full
 *  RGB range.
 *
 *  The brightness threshold value is normalized between [WW_LIGHT_BRIGHTNESS_MIN, WW_LIGHT_BRIGHTNESS_MAX].
 */
@interface WWCommandLightMono : WWCommand

/**
 *  The normalized brightness value of the light, between [WW_LIGHT_BRIGHTNESS_MIN, WW_LIGHT_BRIGHTNESS_MAX].
 */
@property (nonatomic) double brightness;

/**
 *  Initializes the command with specified brightness.
 *
 *  @param brightness The normalized brightness value between [WW_LIGHT_BRIGHTNESS_MIN, WW_LIGHT_BRIGHTNESS_MAX].
 *
 *  @return Returns a newly initialized `WWCommandLightMono` instance.
 */
- (id) initWithBrightness:(double)brightness;

@end
