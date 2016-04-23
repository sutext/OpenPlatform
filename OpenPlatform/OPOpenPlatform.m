//
//  OPOpenPlatform.m
//  OpenPlatform
//
//  Created by supertext on 15/10/6.
//  Copyright © 2015年 icegent. All rights reserved.
//


#import <EasyTools/EasyTools.h>
#import "OPOpenPlatform.h"
#import "OPShareMedia.h"
#import "OPAuthObject.h"
#import "OPPaymentOrder.h"

#import "OPWeixinPayment.h"
#import "OPTencentPlatform.h"
#import "OPWeixinPlatform.h"

#ifdef ALLOW_ALIPAY
#import <AlipaySDK/AlipaySDK.h>
#import "OPAlipayPayment.h"
#endif

#ifdef ALLOW_WEIBO
#import "OPWeiboPlatform.h"
#endif
@interface OPOpenPlatform()
#ifdef ALLOW_ALIPAY
@property(nonatomic,strong)OPAlipayPayment *alipay;
#endif
@property(nonatomic,strong)OPWeixinPayment *weixin;
@property(nonatomic)BOOL  debugEnable;
@property(nonatomic,strong)OPTencentPlatform *qqplatform;
@property(nonatomic,strong)OPWeixinPlatform *wxplatform;
#ifdef ALLOW_WEIBO
@property(nonatomic,strong)OPWeiboPlatform  *wbplatform;
#endif
#ifdef ALLOW_ALIPAY
#endif
@end

@implementation OPOpenPlatform

- (instancetype)init
{
    self = [super init];
    if (self) {

        self.weixin = [[OPWeixinPayment alloc] init];
        self.wxplatform = [[OPWeixinPlatform alloc] init];
#ifdef ALLOW_ALIPAY
        self.alipay = [[OPAlipayPayment alloc] init];
#endif
#ifdef ALLOW_WEIBO
        self.wbplatform = [[OPWeiboPlatform alloc] init];
#endif
        
    }
    return self;
}
-(void)configWeixin:(OPPlatformConfig *)weixinConfig
{
    self.weixin.appid           = weixinConfig.appid;
    self.weixin.signkey          = weixinConfig.signkey;
    self.weixin.partnerid       = weixinConfig.partnerid;
    self.wxplatform.appkey      = weixinConfig.appkey;
    self.wxplatform.appid       = weixinConfig.appid;
    
    [WXApi registerApp:         self.weixin.appid];
}
-(void)configTencent:(OPPlatformConfig *)tencentConfig
{
    self.qqplatform = [[OPTencentPlatform alloc] initWithAppid:tencentConfig.appid];
    self.qqplatform.schema = tencentConfig.schema;
}

-(void)configAlipay:(OPPlatformConfig *)alipayConfig
{
#ifdef ALLOW_ALIPAY
    self.alipay.appid       = alipayConfig.appid;
    self.alipay.appkey      = alipayConfig.appkey;
    self.alipay.partnerid   = alipayConfig.partnerid;
    self.alipay.scheme      = alipayConfig.schema;
    self.alipay.sellerid    = alipayConfig.sellerid;
    self.alipay.signer      = [ETDecryptor decryptorWithPath:alipayConfig.rsakeyPath passwd:alipayConfig.rsakeyPasswd];
#endif
}
-(void)configWeibo:(OPPlatformConfig *)weiboConfig
{
#ifdef ALLOW_WEIBO
    [WeiboSDK registerApp:weiboConfig.appid];
#endif
}
#pragma mark - - open interface
-(BOOL)handleOpenURL:(NSURL *)url
{
    if (self.debugEnable)
    {
        NSLog(@"the callback openURL%@",url);
    }
#ifdef ALLOW_ALIPAY
    if ([url.host isEqualToString:@"safepay"])
    {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [self.alipay handlePamentResut:resultDic];
        }];
        return YES;
    }
#endif
    if ([url.scheme hasPrefix:self.weixin.appid]) {
        if ([url.host hasPrefix:@"pay"]) {
           [WXApi handleOpenURL:url delegate:self.weixin];
        }
        else
        {
            [WXApi handleOpenURL:url delegate:self.wxplatform];
        }
        return YES;
    }
#ifdef ALLOW_WEIBO
    if ([url.scheme hasPrefix:self.weiboConfig.schema])
    {
        return [WeiboSDK handleOpenURL:url delegate:self.wbplatform];
    }
#endif
    if([[url scheme] isEqualToString:self.qqplatform.schema])
    {
        return [QQApiInterface handleOpenURL:url delegate:self.qqplatform];
    }
    return NO;
}

-(void)paymentWithType:(OPOpenPaymentType)payType order:(OPPaymentOrder *)order completed:(void (^)(OPPlatformError, OPPaymentOrder *))completedBlock
{
    if (self.debugEnable)
    {
        NSLog(@"the order info to be send%@",order);
    }
    switch (payType) {
#ifdef ALLOW_ALIPAY
        case OPOpenPaymentTypeAlipay:
        {
            [self.alipay payWithOrder:order completed:^(BOOL isok, OPPaymentOrder *aorder) {
                if (completedBlock) {
                    completedBlock(isok?OPPlatformErrorSucceed:OPPlatformErrorCancel,aorder);
                }
            }];
            break;
        }
#endif
        case OPOpenPaymentTypeWeixin:
        {
            if (![WXApi isWXAppInstalled]) {
                if (completedBlock) {
                    completedBlock(OPPlatformErrorNotInstall,order);
                }
            }
            else
            {
                [self.weixin payWithOrder:order completed:^(BOOL isok, OPPaymentOrder *aorder) {
                    if (completedBlock) {
                        completedBlock(isok?OPPlatformErrorSucceed:OPPlatformErrorCancel,aorder);
                    }
                }];
            }
            break;
        }
        default:
            break;
    }
}

-(void)shareWithType:(OPOpenShareType)shareType media:(OPShareMedia *)media completed:(void (^)(OPPlatformError,OPOpenShareType,OPShareMedia *))completedBlock
{
    switch (shareType) {
        case OPOpenShareTypeQQ:
        {
            [self.qqplatform shareWithMedia:media isChart:YES completed:^(NSInteger errorCode) {
                if (completedBlock) {
                    completedBlock(errorCode,shareType,media);
                }
            }];
            break;
        }
        case OPOpenShareTypeQQZone:
        {
            [self.qqplatform shareWithMedia:media isChart:NO completed:^(NSInteger errorCode) {
                if (completedBlock) {
                    completedBlock(errorCode,shareType,media);
                }
            }];
            break;
        }
        case OPOpenShareTypeWeixin:
        {
            [self.wxplatform shareWithMedia:media isChart:YES completed:^(NSInteger errorCode) {
                if (completedBlock) {
                    completedBlock(errorCode,shareType,media);
                }
            }];
            break;
        }
        case OPOpenShareTypeMoments:
        {
            [self.wxplatform shareWithMedia:media isChart:NO completed:^(NSInteger errorCode) {
                if (completedBlock) {
                    completedBlock(errorCode,shareType,media);
                }
            }];
            break;
        }
#ifdef ALLOW_WEIBO
        case OPOpenShareTypeWeibo:
        {
            [self.wbplatform shareWithMedia:media redirectURI:self.weiboConfig.redirectURI completed:^(NSInteger errorCode) {
                if (completedBlock) {
                    completedBlock(errorCode,media);
                }
            }];
            
            break;
        }
#endif
        default:
            break;
    }
}

-(void)authWithType:(OPOpenAuthType)authType completed:(void (^)(OPPlatformError, OPAuthObject *))completedBlock
{
    switch (authType) {
        case OPOpenAuthTypeQQ:
            
            break;
        case OPOpenAuthTypeWeixin:
        {
            [self.wxplatform authCompleted:^(NSInteger errorCode, OPAuthObject *auth) {
                if (completedBlock) {
                    completedBlock(errorCode,auth);
                }
            }];
            break;
        }
#ifdef ALLOW_WEIBO
        case OPOpenAuthTypeWeibo:
            
            break;
#endif
#ifdef ALLOW_WEIBO
        case OPOpenAuthTypeAlipay:
            
            break;
#endif
        default:
            break;
    }
}
@end
@implementation OPPlatformConfig
- (instancetype)initWithAppid:(NSString *)appid appkey:(NSString *)appkey schema:(NSString *)schema
{
    self = [super init];
    if (self) {
        self.appid = appid;
        self.appkey = appkey;
        self.schema = schema;
    }
    return self;
}
@end
