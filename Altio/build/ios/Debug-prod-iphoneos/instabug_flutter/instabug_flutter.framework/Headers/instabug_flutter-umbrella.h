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

#import "ApmPigeon.h"
#import "BugReportingPigeon.h"
#import "CrashReportingPigeon.h"
#import "FeatureRequestsPigeon.h"
#import "InstabugLogPigeon.h"
#import "InstabugPigeon.h"
#import "RepliesPigeon.h"
#import "SessionReplayPigeon.h"
#import "SurveysPigeon.h"
#import "InstabugFlutterPlugin.h"
#import "ApmApi.h"
#import "BugReportingApi.h"
#import "CrashReportingApi.h"
#import "FeatureRequestsApi.h"
#import "InstabugApi.h"
#import "InstabugLogApi.h"
#import "RepliesApi.h"
#import "SessionReplayApi.h"
#import "SurveysApi.h"
#import "ArgsRegistry.h"
#import "IBGAPM+PrivateAPIs.h"
#import "IBGCrashReporting+CP.h"
#import "IBGNetworkLogger+CP.h"
#import "IBGTimeIntervalUnits.h"

FOUNDATION_EXPORT double instabug_flutterVersionNumber;
FOUNDATION_EXPORT const unsigned char instabug_flutterVersionString[];

