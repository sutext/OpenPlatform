//
//  OPWeiboPlatform.h
//  OpenPlatform
//
//  Created by supertext on 15/10/11.
//  Copyright © 2015年 icegent. All rights reserved.
//
#ifdef ALLOW_WEIBO

#import <Foundation/Foundation.h>
#import <CoreTelephony/CoreTelephonyDefines.h>
#import <AdSupport/AdSupport.h>
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>
#import "WeiboSDK.h"

@class OPShareMedia;
@interface OPWeiboPlatform : NSObject<WBHttpRequestDelegate,WeiboSDKDelegate>
-(void)shareWithMedia:(OPShareMedia *)media redirectURI:(NSString *)redirectURI completed:(void (^)(NSInteger errorCode)) completedBlock;
@end
#endif