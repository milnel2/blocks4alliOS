//
//  WWErrorCode.h
//  APIObjectiveC
//
//  Created by mike on 4/8/15.
//  Copyright (c) 2015 play-i. All rights reserved.
//

#ifndef APIObjectiveC_WWErrorCode_h
#define APIObjectiveC_WWErrorCode_h

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

typedef enum {
    WW_ERR_UNKNOWN = 0,
    WW_ERR_FAILED_SELECT,    // likely BTLE failed to connect to robot
    WW_ERR_CANCELED_SELECT,  // selection mode was canceled (eg, by selecting another robot)
    WW_ERR_FAILED_CONNECT,   // timeout or disconnect while waiting for physical access
    WW_ERR_TIMEOUT,          // generic timeout error
    WW_ERR_DISCONNECTED,     // robot is disconnected and cannot complete the action
} WWErrorCode;

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif
