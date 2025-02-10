//
//  IBGProactiveReportingConfigurations.h
//  InstabugBugReporting
//
//  Created by Eyad on 26/05/2024.
//  Copyright © 2024 Instabug. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
NS_SWIFT_NAME(ProactiveReportingConfigurations)
/// Configurations that control Proactive Reporting
@interface IBGProactiveReportingConfigurations : NSObject

/**
 @brief Sets whether Proactive Reporting  is enabled  or not.
 
 @discussion Proactive Reporting is disabled by default.
 */
@property(nonatomic, assign) BOOL enabled;
/**
 @brief Controls the delay in time between detecting a frustrating experience and showing the proactive reporting alert represented as seconds.
 */
@property(nonatomic, strong, nullable) NSNumber *modalDelayAfterDetection;
/**
 @brief Controls the time gap between detecting a frustrating experience and showing the proactive reporting alert represented in seconds.
 
 @discussion Proactive Reporting alert won't be shown again until this duration in seconds has passed
 */
@property(nonatomic, strong, nullable) NSNumber *gapBetweenModals;

@end

NS_ASSUME_NONNULL_END
