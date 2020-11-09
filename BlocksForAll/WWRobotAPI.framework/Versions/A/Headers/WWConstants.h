//
//  WWConstants.h
//  APIObjectiveC
//
//  Created by Orion Elenzil on 20140918.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.
//

#ifndef APIObjectiveC_WWConstants_h
#define APIObjectiveC_WWConstants_h

// todo: convert into typedef, as well as making everything to be #define
// hide others in WWConstants_Internal.h

/** number constant definitions **/

// max/min boundaries
#define WW_LIGHT_BRIGHTNESS_MAX 1.0
#define WW_LIGHT_BRIGHTNESS_MIN 0.0
#define WW_ANGLE_UNDEFINED NAN
#define WW_VOLUME_MAX 1.0
#define WW_VOLUME_MUTE 0.0
#define WW_VOLUME_UNDEFINED 1.1

#define WW_EYE_BRIGHTNESS_UNDEFINED 1.1
#define WW_EYE_BRIGHTNESS_MAX 1.0
#define WW_EYE_BRIGHTNESS_MIN 0.0

#define WW_LAUNCHER_POWER_MIN 0.0
#define WW_LAUNCHER_POWER_MAX 1.0
typedef unsigned int WWLauncherReloadDirection;
#define WW_LAUNCHER_RELOAD_LEFT 1
#define WW_LAUNCHER_RELOAD_RIGHT 2

// on-robot file syntax definitions
#define WW_ON_ROBOT_DIR_LENGTH 4
#define WW_ON_ROBOT_FILE_MIN_LENGTH 1
#define WW_ON_ROBOT_FILE_MAX_LENGTH 10
#define WW_ON_ROBOT_DIR_AND_FILE_MAX_LENGTH (WW_ON_ROBOT_DIR_LENGTH + WW_ON_ROBOT_FILE_MAX_LENGTH)
#define WW_ON_ROBOT_EXT_LENGTH 2           // not used, but for the record


// defines for componentIds (used for CommandSet and SensorSet)
typedef unsigned int WWComponentId;
#define WW_COMMAND_POWER 1
#define WW_COMMAND_EYE_RING 100
#define WW_COMMAND_LIGHT_RGB_EYE 101
#define WW_COMMAND_LIGHT_RGB_LEFT_EAR 102
#define WW_COMMAND_LIGHT_RGB_RIGHT_EAR 103
#define WW_COMMAND_LIGHT_RGB_CHEST 104
#define WW_COMMAND_LIGHT_MONO_TAIL 105
#define WW_COMMAND_LIGHT_MONO_BUTTON_MAIN 106
#define WW_COMMAND_HEAD_POSITION_TILT 202
#define WW_COMMAND_HEAD_POSITION_PAN 203
#define WW_COMMAND_BODY_LINEAR_ANGULAR 204
#define WW_COMMAND_BODY_POSE 205
#define WW_COMMAND_MOTOR_HEAD_BANG 210
#define WW_COMMAND_BODY_WHEELS 211
#define WW_COMMAND_BODY_COAST 212
#define WW_COMMAND_SPEAKER 300
#define WW_COMMAND_ON_ROBOT_ANIM 301
#define WW_COMMAND_LAUNCHER_FLING 400
#define WW_COMMAND_LAUNCHER_RELOAD 401
#define WW_SENSOR_BUTTON_MAIN 1000
#define WW_SENSOR_BUTTON_1 1001
#define WW_SENSOR_BUTTON_2 1002
#define WW_SENSOR_BUTTON_3 1003
#define WW_SENSOR_HEAD_POSITION_PAN 2000
#define WW_SENSOR_HEAD_POSITION_TILT 2001
#define WW_SENSOR_BODY_POSE 2002
#define WW_SENSOR_ACCELEROMETER 2003
#define WW_SENSOR_GYROSCOPE 2004
#define WW_SENSOR_DISTANCE_FRONT_LEFT_FACING 3000
#define WW_SENSOR_DISTANCE_FRONT_RIGHT_FACING 3001
#define WW_SENSOR_DISTANCE_BACK 3002
#define WW_SENSOR_ENCODER_LEFT_WHEEL 3003
#define WW_SENSOR_ENCODER_RIGHT_WHEEL 3004
#define WW_SENSOR_MICROPHONE 3005


typedef unsigned int WWRobotType;
#define WW_ROBOT_UNKNOWN 1000
#define WW_ROBOT_DASH 1001
#define WW_ROBOT_DOT 1002

typedef unsigned int WWPersonalityColorIndex;
#define WW_PERSONALITY_COLOR_NONE      0            // aka white
#define WW_PERSONALITY_COLOR_YELLOW    1            // do not renumber these!
#define WW_PERSONALITY_COLOR_GREEN     2
#define WW_PERSONALITY_COLOR_ORANGE    3
#define WW_PERSONALITY_COLOR_BLUE      4
#define WW_PERSONALITY_COLOR_RED       5
#define WW_PERSONALITY_COLOR_PURPLE    6
#define WW_PERSONALITY_COLOR_INVALID 255

typedef unsigned int WWRobotColorIndex; // same as WWPersonalityColorIndex with additional values.
#define WW_ROBOT_COLOR_WHITE    WW_PERSONALITY_COLOR_NONE
#define WW_ROBOT_COLOR_YELLOW   WW_PERSONALITY_COLOR_YELLOW
#define WW_ROBOT_COLOR_GREEN    WW_PERSONALITY_COLOR_GREEN
#define WW_ROBOT_COLOR_ORANGE   WW_PERSONALITY_COLOR_ORANGE
#define WW_ROBOT_COLOR_BLUE     WW_PERSONALITY_COLOR_BLUE
#define WW_ROBOT_COLOR_RED      WW_PERSONALITY_COLOR_RED
#define WW_ROBOT_COLOR_PURPLE   WW_PERSONALITY_COLOR_PURPLE
#define WW_ROBOT_COLOR_BLUE2   (WW_PERSONALITY_COLOR_PURPLE + 1)
#define WW_ROBOT_COLOR_OFF     (WW_PERSONALITY_COLOR_PURPLE + 2)
#define WW_ROBOT_COLOR_INVALID  WW_PERSONALITY_COLOR_INVALID


typedef unsigned int WWPersonalityAnimationIndex;
#define WW_PERSONALITY_ANIMATION_NONE 0
#define WW_PERSONALITY_ANIMATION_1 1
#define WW_PERSONALITY_ANIMATION_2 2
#define WW_PERSONALITY_ANIMATION_3 3
#define WW_PERSONALITY_ANIMATION_INVALID 255

typedef unsigned int WWBeaconDataType;
#define WW_BEACON_DATA_TYPE_COLOR 0
#define WW_BEACON_DATA_TYPE_USER  1

#define WW_BEACON_RECEIVER_LEFT  (1 << 0)
#define WW_BEACON_RECEIVER_RIGHT (1 << 1)



#define ROBOT_NAME_SIZE 18

/** string constant definitions **/
#if __OBJC__
#define __wwstr__ @
#else
#define __wwstr__
#endif

#define WW_SOUND_SYSTEM_DIR                               __wwstr__"SYST"
#define WW_ANIM_SYSTEM_DIR                                __wwstr__"SYST"
#define WW_COMMAND_SEQUENCE_DATA                          __wwstr__"data"
#define WW_COMMAND_SET_DURATION                           __wwstr__"duration"
#define WW_COMMAND_SET_VALUES                             __wwstr__"commands"

#define WW_COMMAND_VALUE_LEFT_SPEED                       __wwstr__"left_cm_s"
#define WW_COMMAND_VALUE_RIGHT_SPEED                      __wwstr__"right_cm_s"
#define WW_COMMAND_VALUE_SPEED_LINEAR                     __wwstr__"linear_cm_s"
#define WW_COMMAND_VALUE_SPEED_ANGULAR_RAD                __wwstr__"angular_cm_s"
#define WW_COMMAND_VALUE_SPEED_ANGULAR_DEG                __wwstr__"angular_deg_s"
#define WW_COMMAND_VALUE_ACCELERATION_LINEAR              __wwstr__"linear_acc_cm_s_s"
#define WW_COMMAND_VALUE_ACCELERATION_ANGULAR             __wwstr__"angular_acc_deg_s_s"
#define WW_COMMAND_VALUE_USE_POSE                         __wwstr__"pose"


#define WW_COMMAND_VALUE_ANGLE_DEGREE                     __wwstr__"degree"
#define WW_COMMAND_VALUE_ANGLE_RADIAN                     __wwstr__"radian"

#define WW_COMMAND_VALUE_COLOR_BRIGHTNESS                 __wwstr__"brightness"
#define WW_COMMAND_VALUE_COLOR_RED                        __wwstr__"r"
#define WW_COMMAND_VALUE_COLOR_GREEN                      __wwstr__"g"
#define WW_COMMAND_VALUE_COLOR_BLUE                       __wwstr__"b"
#define WW_COMMAND_VALUE_ORDER_INDEX                      __wwstr__"index"


typedef enum {
  WW_POSE_MODE_GLOBAL = 0,
  WW_POSE_MODE_RELATIVE_COMMAND,
  WW_POSE_MODE_RELATIVE_MEASURED,
  WW_POSE_MODE_SET_GLOBAL,
  WW_POSE_MODE_SET_TEMP_GLOBAL,
  WW_POSE_MODE_TEMP_GLOBAL
} WWPoseMode;

typedef enum {
  WW_POSE_DIRECTION_FORWARD = 0,
  WW_POSE_DIRECTION_BACKWARD,
  WW_POSE_DIRECTION_INFERRED,
} WWPoseDirection;

typedef enum {
  WW_POSE_WRAP_OFF = 0,
  WW_POSE_WRAP_ON,
} WWPoseWrap;

#undef wwstr

#endif