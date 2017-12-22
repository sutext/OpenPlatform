//
//  OPOpenPlatform.h
//  OpenPlatform
//
//  Created by supertext on 15/10/6.
//  Copyright © 2015年 icegent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenPlatform/OPPlatformProtocol.h>

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

typedef NS_ENUM(NSUInteger, OPOpenShareType) {
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
    OPOpenAuthTypeAlipay,
};

@class OPShareObject;
@class OPAuthObject;

NS_CLASS_AVAILABLE_IOS(8_0)
@interface OPOpenPlatform : NSObject
-(void)setDebugEnable:(BOOL) enable;
-(void)configAlipay:(NSString*)appid schema:(NSString *)schema;
-(void)configWechat:(NSString*)appid appkey:(NSString *)appkey;
-(void)configWeibo:(NSString *)appid schema:(NSString *)schema redirectURI:(NSString *)redirectURI;
-(void)configTencent:(NSString *)appid appkey:(NSString *)appkey;
-(BOOL)handleOpenURL:(NSURL *)url;//you mast call this method in application:openURL:sourceApplication;
-(void)shareWithType:(OPOpenShareType)shareType
               media:(OPShareObject *)media
           completed:(nullable void (^)(OPPlatformError errorCode,OPOpenShareType,OPShareObject *)) completedBlock;
-(void)authWithType:(OPOpenAuthType)authType
          completed:(nullable void (^)(OPPlatformError,NSString  * _Nullable )) completedBlock;
@end

@interface OPOpenPlatform(auth)
@property(nonatomic,strong,readonly)id<OPPlatformProtocol> qq;
@property(nonatomic,strong,readonly)id<OPPlatformProtocol> wechat;
@property(nonatomic,strong,readonly)id<OPWeiboProtocol> weibo;
@end
@interface OPOpenPlatform(payment)
@property(nonatomic,strong,readonly)id<OPPlatformPayment> alipay;
@property(nonatomic,strong,readonly)id<OPPlatformPayment> weipay;
@end
NS_ASSUME_NONNULL_END
