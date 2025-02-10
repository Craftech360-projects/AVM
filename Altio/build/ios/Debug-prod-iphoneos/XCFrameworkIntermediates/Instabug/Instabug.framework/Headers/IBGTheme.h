//
//  IBGTheme.h
//  InstabugCoreInternal
//
//  Created by Eyad on 15/07/2024.
//  Copyright © 2024 Instabug. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Theme)
@interface IBGTheme : NSObject

@property (strong) UIFont *primaryTextFont;
@property (strong) UIFont *secondaryTextFont;
@property (strong) UIFont *callToActionTextFont;


@property (strong) UIColor *primaryColor;
@property (strong) UIColor *backgroundColor;


@property (strong) UIColor *titleTextColor;
@property (strong) UIColor *subtitleTextColor;
@property (strong) UIColor *primaryTextColor;
@property (strong) UIColor *secondaryTextColor;
@property (strong) UIColor *callToActionTextColor;


@property (strong) UIColor *headerBackgroundColor;
@property (strong) UIColor *footerBackgroundColor;
@property (strong) UIColor *rowBackgroundColor;

@property (strong) UIColor *rowSeparatorColor;

@property (strong) UIColor *selectedRowBackgroundColor;

@end

NS_ASSUME_NONNULL_END
