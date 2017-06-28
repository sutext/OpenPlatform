//
//  OPOpenPlatform.m
//  OpenPlatform
//
//  Created by supertext on 15/10/6.
//  Copyright © 2015年 icegent. All rights reserved.
//


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
-(void)configWechat:(OPPlatformConfig *)wechat
{
    self.weixin.appid           = wechat.appid;
    self.weixin.signkey         = wechat.signkey;
    self.weixin.partnerid       = wechat.partnerid;
    self.wxplatform.appkey      = wechat.appkey;
    self.wxplatform.appid       = wechat.appid;
    
    [WXApi registerApp:wechat.appid enableMTA:NO];
}
-(void)configTencent:(OPPlatformConfig *)tencent
{
    self.qqplatform = [[OPTencentPlatform alloc] initWithAppid:tencent.appid];
    self.qqplatform.schema = tencent.schema;
}

-(void)configAlipay:(OPPlatformConfig *)alipay
{
#ifdef ALLOW_ALIPAY
    self.alipay.appid       = alipay.appid;
    self.alipay.appkey      = alipay.appkey;
    self.alipay.partnerid   = alipay.partnerid;
    self.alipay.scheme      = alipay.schema;
    self.alipay.sellerid    = alipay.sellerid;
    self.alipay.signer      = [ETDecryptor decryptorWithPath:alipay.rsakeyPath passwd:alipayConfig.rsakeyPasswd];
#endif
}
-(void)configWeibo:(OPPlatformConfig *)weibo
{
#ifdef ALLOW_WEIBO
    [WeiboSDK registerApp:weibo.appid];
    self.wbplatform.redirectURI = weibo.redirectURI;
    self.wbplatform.schema = weibo.schema;
#endif
}
-(void)setDebugEnable:(BOOL)enable
{
    if (_debugEnable!=enable) {
        _debugEnable=enable;
    }
    [WeiboSDK enableDebugMode:enable];
}
#pragma mark - - open interface
-(BOOL)handleOpenURL:(NSURL *)url
{
    if (self.debugEnable)
    {
        NSLog(@"the callback openURL:\n%@",url);
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
    if ([url.scheme hasPrefix:self.wbplatform.schema])
    {
        return [WeiboSDK handleOpenURL:url delegate:self.wbplatform];
    }
#endif
    if([[url scheme] hasPrefix:@"tencent"])
    {
        return [self.qqplatform handleOpenURL:url];
    }
    if ([[url scheme] hasPrefix:@"QQ"]) {
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
        case OPOpenPaymentTypeWechat:
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
        case OPOpenShareTypeWechat:
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
            [self.wbplatform shareWithMedia:media redirectURI:self.wbplatform.redirectURI completed:^(NSInteger errorCode) {
                if (completedBlock) {
                    completedBlock(errorCode,shareType,media);
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
        {
            [self.qqplatform authCompleted:^(NSInteger errorCode, OPAuthObject *auth) {
                if (completedBlock) {
                    completedBlock(errorCode,auth);
                }
            }];
        }
            break;
        case OPOpenAuthTypeWechat:
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
        {
            [self.wbplatform authCompleted:^(NSInteger errorCode, OPAuthObject *auth) {
                if (completedBlock) {
                    completedBlock(errorCode,auth);
                }
            }];
        }
            break;
#endif
#ifdef ALLOW_Alipay
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
