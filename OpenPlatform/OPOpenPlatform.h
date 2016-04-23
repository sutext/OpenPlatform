//
//  OPOpenPlatform.h
//  OpenPlatform
//
//  Created by supertext on 15/10/6.
//  Copyright © 2015年 icegent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, OPPlatformError) {
    OPPlatformErrorUnknown,
    OPPlatformErrorSucceed,
    OPPlatformErrorNetwork,
    OPPlatformErrorCancel,
    OPPlatformErrorRefuse,
    OPPlatformErrorNotInstall,
    OPPlatformErrorUnsuport,
    OPPlatformErrorException,
};

typedef NS_ENUM(NSUInteger, OPOpenPaymentType) {
    OPOpenPaymentTypeAlipay,
    OPOpenPaymentTypeWeixin,
};

typedef NS_ENUM(NSUInteger, OPOpenShareType) {
    OPOpenShareTypeUnknown,
    OPOpenShareTypeQQ,
    OPOpenShareTypeQQZone,
    OPOpenShareTypeWeixin,
    OPOpenShareTypeMoments,
    OPOpenShareTypeWeibo,
};

typedef NS_ENUM(NSUInteger, OPOpenAuthType) {
    OPOpenAuthTypeUnknown,
    OPOpenAuthTypeQQ,
    OPOpenAuthTypeWeixin,
    OPOpenAuthTypeWeibo,
    OPOpenAuthTypeAlipay,
};
@interface OPPlatformConfig:NSObject
-(instancetype)initWithAppid:(nullable NSString *)appid appkey:(nullable NSString *)appkey schema:(nullable NSString *)schema;
@property(nonatomic,strong,nullable)NSString *appid;//all
@property(nonatomic,strong,nullable)NSString *appkey;//all
@property(nonatomic,strong,nullable)NSString *schema;//all
@property(nonatomic,strong,nullable)NSString *signkey;//weipay
@property(nonatomic,strong,nullable)NSString *rsakeyPath;//alipay
@property(nonatomic,strong,nullable)NSString *rsakeyPasswd;//alipay
@property(nonatomic,strong,nullable)NSString *sellerid;//alipay
@property(nonatomic,strong,nullable)NSString *partnerid;//alipay weixin
@property(nonatomic,strong,nullable)NSString *redirectURI;//weibo
@end

@class OPPaymentOrder;
@class OPShareMedia;
@class OPAuthObject;

@interface OPOpenPlatform : NSObject

-(void)setDebugEnable:(BOOL) enable;
-(void)configAlipay:(OPPlatformConfig *)alipayConfig;
-(void)configWeixin:(OPPlatformConfig *)weixinConfig;
-(void)configWeibo:(OPPlatformConfig *)weiboConfig;
-(void)configTencent:(OPPlatformConfig *)tencentConfig;
-(BOOL)handleOpenURL:(NSURL *)url;//you mast call this method in application:openURL:sourceApplication;

-(void)paymentWithType:(OPOpenPaymentType)payType
                 order:(OPPaymentOrder *)order
             completed:(nullable void (^)(OPPlatformError errorCode,OPPaymentOrder *order)) completedBlock;

-(void)shareWithType:(OPOpenShareType)shareType
               media:(OPShareMedia *)media
           completed:(nullable void (^)(OPPlatformError errorCode,OPOpenShareType,OPShareMedia *media)) completedBlock;

-(void)authWithType:(OPOpenAuthType)authType
          completed:(nullable void (^)(OPPlatformError errorCode,OPAuthObject *auth)) completedBlock;
@end
NS_ASSUME_NONNULL_END