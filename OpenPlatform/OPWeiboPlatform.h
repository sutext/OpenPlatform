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

@protocol OPShareObject;
@class OPAuthObject;
NS_ASSUME_NONNULL_BEGIN
@interface OPWeiboPlatform : NSObject<WBHttpRequestDelegate,WeiboSDKDelegate>
@property(nonatomic,strong)NSString *redirectURI;
@property(nonatomic,strong)NSString *schema;
@property(strong,nullable,readonly)NSString * installURL;
-(void)shareWithMedia:(id<OPShareObject>)media redirectURI:(NSString *)redirectURI completed:(void (^)(NSInteger errorCode)) completedBlock;
-(void)authCompleted:(void (^)(NSInteger errorCode,OPAuthObject *auth)) completedBlock;
@end
NS_ASSUME_NONNULL_END
#endif
