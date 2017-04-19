//
//  WWCommandSpeaker.h
//  APIObjectiveC
//
//  Created by Kevin Liang on 3/31/14.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.
//

#import "WWCommand.h"

/**
 *  The `WWCommandSpeaker` object instructs a `WWRobot` object what sound file to play, if it exists.
 *
 *  The command is a no-op if the sound file does not exist on the robot.
 */
@interface WWCommandSpeaker : WWCommand

/**
 *  Specifies the sound volume, normalized between 0-1.
 */
@property (nonatomic) float volume;

/**
 *  Specifies the sound file to play on the robot.
 */
@property (nonatomic, strong) NSString *fileName;

/**
 *  Specifies the directory name where the sound file is located.
 */
@property (nonatomic, strong) NSString *directory;

/**
 *  Initializes the command with specified fileName, directory, and volume.
 *
 *  @param fileName  The sound file to play.
 *  @param directory The directory that contains the sound file.
 *  @param volume    The volume level for the sound.
 *
 *  @return Returns a newly initialized `WWCommandSpeaker` instance.
 */
- (id) initWithSound:(NSString *)fileName directory:(NSString *)directory volume:(double)volume;

/**
 *  Initializes the command with specified fileName and directory.
 *
 *  Volume will be set to WW_VOLUME_MAX.
 *
 *  @param fileName  The sound file to play.
 *  @param directory The directory that contains the sound file.
 *
 *  @return Returns a newly initialized `WWCommandSpeaker` instance.
 */
- (id) initWithSound:(NSString *)fileName directory:(NSString *)directory;

/**
 *  Initializes the command with specified default sound fileName.
 *
 *  Volume will be set to WW_VOLUME_MAX, and directory will be set to WW_SOUND_SYSTEM_DIR.
 *
 *  @param fileName  The default sound file to play.
 *
 *  @return Returns a newly initialized `WWCommandSpeaker` instance.
 */
- (id) initWithDefaultSound:(NSString *)fileName;

@end
