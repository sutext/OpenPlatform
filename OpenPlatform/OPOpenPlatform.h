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
    OPOpenPaymentTypeWechat,
};

typedef NS_ENUM(NSUInteger, OPOpenShareType) {
    OPOpenShareTypeUnknown,
    OPOpenShareTypeQQ,
    OPOpenShareTypeQQZone,
    OPOpenShareTypeWechat,
    OPOpenShareTypeMoments,
    OPOpenShareTypeWeibo,
};

typedef NS_ENUM(NSUInteger, OPOpenAuthType) {
    OPOpenAuthTypeQQ,
    OPOpenAuthTypeWechat,
    OPOpenAuthTypeWeibo,
};

NS_CLASS_AVAILABLE_IOS(8_0)
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
@protocol OPShareObject;
@class OPAuthObject;

NS_CLASS_AVAILABLE_IOS(8_0)
@interface OPOpenPlatform : NSObject

-(void)setDebugEnable   :(BOOL) enable;
-(void)configAlipay     :(OPPlatformConfig *)alipay;
-(void)configWechat     :(OPPlatformConfig *)wechat;
-(void)configWeibo      :(OPPlatformConfig *)weibo;
-(void)configTencent    :(OPPlatformConfig *)tencent ;

-(BOOL)handleOpenURL    :(NSURL *)url;//you mast call this method in application:openURL:sourceApplication;

-(void)paymentWithType:(OPOpenPaymentType)payType
                 order:(OPPaymentOrder *)order
             completed:(nullable void (^)(OPPlatformError errorCode,OPPaymentOrder *order)) completedBlock;

-(void)shareWithType:(OPOpenShareType)shareType
               media:(id<OPShareObject>)media
           completed:(nullable void (^)(OPPlatformError errorCode,OPOpenShareType,id<OPShareObject>)) completedBlock;

-(void)authWithType:(OPOpenAuthType)authType
          completed:(nullable void (^)(OPPlatformError errorCode,OPAuthObject *auth)) completedBlock;
-(nullable NSString *)installURLWithType:(OPOpenAuthType)type;
@end
NS_ASSUME_NONNULL_END
