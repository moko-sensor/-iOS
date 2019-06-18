#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MKSocketAdopter.h"
#import "MKSocketBlockAdopter.h"
#import "MKSocketManager.h"
#import "MKSocketTaskDefine.h"
#import "MKSocketTaskOperation.h"
#import "MKMQTTServerManager.h"
#import "MKMQTTServerTaskOperation.h"

FOUNDATION_EXPORT double MKSensorVersionNumber;
FOUNDATION_EXPORT const unsigned char MKSensorVersionString[];

