//
//  OPWeiboPlatform.h
//  OpenPlatform
//
//  Created by supertext on 15/10/11.
//  Copyright © 2015年 icegent. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreTelephony/CoreTelephonyDefines.h>
#import <AdSupport/AdSupport.h>
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <OpenPlatform/OPPlatformProtocol.h>

@class OPShareObject;
@class OPAuthObject;
NS_ASSUME_NONNULL_BEGIN
@interface OPWeiboPlatform : NSObject<OPWeiboProtocol>
-(instancetype)initWithAppid:(NSString*)appid schema:(NSString *)schema redirectURI:(NSString *)redirectURI;
@property(nonatomic,strong)NSString *redirectURI;
@property(nonatomic,strong)NSString *schema;
@property(nonatomic,strong)NSString *appid;
-(void)setDebugEnable:(BOOL)enable;
-(void)shareWithMedia:(OPShareObject *)media redirectURI:(NSString *)redirectURI completed:(void (^)(NSInteger errorCode)) completedBlock;
-(void)authCompleted:(void (^)(NSInteger errorCode,NSString *token)) completedBlock;
@end
NS_ASSUME_NONNULL_END

