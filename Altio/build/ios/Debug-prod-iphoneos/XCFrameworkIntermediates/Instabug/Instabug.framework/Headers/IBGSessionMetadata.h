//
//  IBGSessionMetadata.h
//  Instabug
//
//  Created by Instabug on 12/08/2024.
//  Copyright © 2024 Instabug. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SessionMetadataNetworkLogs;

typedef NS_ENUM(NSInteger, LaunchType) {
    LaunchTypeCold = 0,
    LaunchTypeHot = 1,
    LaunchTypeUnknown = -1
};

NS_SWIFT_NAME(SessionMetadataNetworkLogs)
@interface IBGSessionMetadataNetworkLogs : NSObject

@property (nonatomic, copy, nullable) NSString *url;
@property (nonatomic, assign) NSInteger duration; // in milliseconds
@property (nonatomic, assign) NSInteger statusCode;

@end

NS_SWIFT_NAME(SessionMetadata)
@interface IBGSessionMetadata : NSObject

@property (nonatomic, copy, nullable) NSString *device;
@property (nonatomic, copy, nullable) NSString *os;
@property (nonatomic, copy, nullable) NSString *appVersion;
/// sessionDuration in seconds
@property (nonatomic, assign) NSInteger sessionDuration;
@property (nonatomic, assign) BOOL hasLinkToAppReview;
@property (nonatomic, assign) LaunchType launchType;
@property (nonatomic, assign) NSInteger launchDuration; // in milliseconds
@property (nonatomic, assign) NSInteger bugsCount;
@property (nonatomic, assign) NSInteger fatalCrashCount;
@property (nonatomic, assign) NSInteger oomCrashCount;
@property (nonatomic, copy, nullable) NSArray<IBGSessionMetadataNetworkLogs *> *networkLogs;

@end
