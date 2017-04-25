//
//  WWCommandLauncherFling.h
//  APIObjectiveC
//
//  Created by Kevin Liang on 10/6/2015.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.
//

#import "WWCommand.h"

/**
 *  `WWCommandLauncherFling` objects instruct a `WWRobot` to perform a decisive head fling motion that will trigger a launch.
 *  This command object requires the ball launcher accessory to be attached to dash.
 */
@interface WWCommandLauncherFling : WWCommand

@property (nonatomic) double power;

- (id) initWithPower:(double)power;

@end
