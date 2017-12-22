//
//  OPOpenPlatform.m
//  OpenPlatform
//
//  Created by supertext on 15/10/6.
//  Copyright © 2015年 icegent. All rights reserved.
//


#import "OPOpenPlatform.h"
#import "OPShareMedia.h"

#import "OPWeixinPayment.h"
#import "OPTencentPlatform.h"
#import "OPWeixinPlatform.h"

#import "OPAlipayPayment.h"
#import "OPWeiboPlatform.h"
@interface OPOpenPlatform()
@property(nonatomic)BOOL  debugEnable;
@property(nonatomic,strong)OPAlipayPayment   *alipay;
@property(nonatomic,strong)OPWeixinPayment   *weipay;
@property(nonatomic,strong)OPTencentPlatform *qqplatform;
@property(nonatomic,strong)OPWeixinPlatform  *wxplatform;
@property(nonatomic,strong)OPWeiboPlatform   *wbplatform;
@end

@implementation OPOpenPlatform

-(void)configAlipay:(NSString*)appid schema:(NSString *)schema{
    self.alipay = [[OPAlipayPayment alloc] initWithAppid:appid schema:schema];
}
-(void)configWechat:(NSString*)appid appkey:(NSString *)appkey{
    self.wxplatform = [[OPWeixinPlatform alloc] initWithAppid:appid appkey:appkey];
    self.weipay = [[OPWeixinPayment alloc] init];
}
-(void)configWeibo:(NSString *)appid schema:(NSString *)schema redirectURI:(NSString *)redirectURI{
    self.wbplatform = [[OPWeiboPlatform alloc] initWithAppid:appid schema:schema redirectURI:redirectURI];
}
-(void)configTencent:(NSString *)appid appkey:(NSString *)appkey
{
    self.qqplatform = [[OPTencentPlatform alloc] initWithAppid:appid appkey:appkey];
}
-(void)setDebugEnable:(BOOL)enable
{
    if (_debugEnable!=enable) {
        _debugEnable=enable;
    }
    self.weipay.debugEnable = enable;
    self.alipay.debugEnable = enable;
    [self.wbplatform setDebugEnable:enable];
}
#pragma mark - - open interface
-(BOOL)handleOpenURL:(NSURL *)url
{
    if (self.debugEnable)
    {
        NSLog(@"the callback openURL:\n%@",url);
    }
    if ([url.host isEqualToString:@"safepay"])
    {
        return [self.alipay handelOpenURL:url];
    }
    if (self.wxplatform.appid&&[url.scheme hasPrefix:self.wxplatform.appid]) {
        if ([url.host hasPrefix:@"pay"]) {
            return  [self.weipay handelOpenURL:url];
        }
        else
        {
            return [self.wxplatform handelOpenURL:url];
        }
    }
    if (self.wbplatform.schema&&[url.scheme hasPrefix:self.wbplatform.schema])
    {
        return [self.weibo handelOpenURL:url];
    }
    return [self.qqplatform handelOpenURL:url];
}

-(void)shareWithType:(OPOpenShareType)shareType media:(OPShareObject *)media completed:(void (^)(OPPlatformError, OPOpenShareType, OPShareObject * _Nonnull))completedBlock
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
        case OPOpenShareTypeWeibo:
        {
            [self.wbplatform shareWithMedia:media redirectURI:self.wbplatform.redirectURI completed:^(NSInteger errorCode) {
                if (completedBlock) {
                    completedBlock(errorCode,shareType,media);
                }
            }];
            
            break;
        }
        default:
            break;
    }
}

-(void)authWithType:(OPOpenAuthType)authType completed:(void (^)(OPPlatformError, NSString *))completedBlock
{
    switch (authType) {
        case OPOpenAuthTypeQQ:
        {
            [self.qqplatform authCompleted:^(NSInteger errorCode, NSString *token) {
                if (completedBlock) {
                    completedBlock(errorCode,token);
                }
            }];
        }
            break;
        case OPOpenAuthTypeWechat:
        {
            [self.wxplatform authCompleted:^(NSInteger errorCode, NSString *token) {
                if (completedBlock) {
                    completedBlock(errorCode,token);
                }
            }];
            break;
        }
        case OPOpenAuthTypeWeibo:
        {
            [self.wbplatform authCompleted:^(NSInteger errorCode, NSString *token) {
                if (completedBlock) {
                    completedBlock(errorCode,token);
                }
            }];
        }
            break;
        case OPOpenAuthTypeAlipay:{
            [self.alipay authCompleted:^(NSInteger errorCode, NSString *token) {
                if (completedBlock) {
                    completedBlock(errorCode,token);
                }
            }];
        }
            
            break;
        default:
            break;
    }
}
-(id<OPPlatformProtocol>)qq{
    return  self.qqplatform;
}
-(id<OPPlatformProtocol>)weibo{
    return  self.wbplatform;
}
-(id<OPPlatformProtocol>)wechat{
    return  self.wxplatform;
}
@end

