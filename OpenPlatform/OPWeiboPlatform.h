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
@class OPAuthObject;
@interface OPWeiboPlatform : NSObject<WBHttpRequestDelegate,WeiboSDKDelegate>
@property(nonatomic,strong)NSString *redirectURI;
@property(nonatomic,strong)NSString *schema;
-(void)shareWithMedia:(OPShareMedia *)media redirectURI:(NSString *)redirectURI completed:(void (^)(NSInteger errorCode)) completedBlock;
-(void)authCompleted:(void (^)(NSInteger errorCode,OPAuthObject *auth)) completedBlock;
@end
#endif
