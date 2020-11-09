//
//  WWCommandLauncherReload.h
//  APIObjectiveC
//
//  Created by Kevin Liang on 10/7/15.
//  Copyright (c) 2015 play-i. All rights reserved.
//

#import "WWCommand.h"

/**
 *  `WWCommandLauncherReload` objects instruct a `WWRobot` to perform a reload for the ball flinger.
 *  This command object requires the ball launcher accessory to be attached to dash.
 */
@interface WWCommandLauncherReload : WWCommand

@property (nonatomic) WWLauncherReloadDirection direction;

- (id) initWithDirection:(WWLauncherReloadDirection)direction;
@end
