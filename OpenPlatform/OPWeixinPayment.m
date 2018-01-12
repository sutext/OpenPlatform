//
//  OPWeixinPayment.m
//  OpenPlatform
//
//  Created by supertext on 15/10/8.
//  Copyright © 2015年 icegent. All rights reserved.
//


#import "OPWeixinPayment.h"
#import "WXApi.h"
@interface OPWeixinPayment()<WXApiDelegate>
@property(nonatomic,copy)void (^finishBlock)(OPPaymentStatus);
@end
@implementation OPWeixinPayment
-(void)paymentWithInfo:(OPPaymentInfo *)info finishBlock:(void (^)(OPPaymentStatus))finishBlock{
    if (![WXApi isWXAppInstalled]) {
        if (finishBlock) {
            finishBlock(OPPaymentStatusNotInstall);
        }
        return;
    }
    if (![WXApi isWXAppSupportApi]) {
        if (finishBlock) {
            finishBlock(OPPaymentStatusUnsuport);
        }
        return;
    }
    PayReq* req             = [[PayReq alloc] init];
    req.openID              = info.appid;
    req.partnerId           = info.partnerid;
    req.prepayId            = info.prepayid;
    req.nonceStr            = info.noncestr;
    req.timeStamp           = [info.timestamp intValue];
    req.package             = info.package;
    req.sign                = info.sign;
    self.finishBlock = finishBlock;
    [WXApi sendReq:req];
}
-(BOOL)handelOpenURL:(NSURL *)openURL{
    return [WXApi handleOpenURL:openURL delegate:self];
}

- (BOOL)open {
    return [WXApi openWXApp];
}

-(BOOL)isInstalled{
    return  [WXApi isWXAppInstalled];
}
-(NSString *)installURL{
    return [WXApi getWXAppInstallUrl];
}
#pragma mark - - weixin call back
-(void) onResp:(BaseResp*)resp
{
    if (self.debugEnable)
    {
        NSLog(@"the paymen resp code=%d,error=%@",resp.errCode,resp.errStr);
    }
    if (self.finishBlock){
        int code = resp.errCode;
        OPPaymentStatus status = OPPaymentStatusUnknown;
        switch (code) {
            case WXSuccess:{
                status = OPPaymentStatusSucceed;
                break;
            }
            case WXErrCodeSentFail:{
                status = OPPaymentStatusFailed;
                break;
            }
            case WXErrCodeUserCancel:{
                status = OPPaymentStatusCancel;
                break;
            }
            case WXErrCodeAuthDeny:{
                status  = OPPaymentStatusRefuse;
                break;
            }
            case WXErrCodeUnsupport:{
                status = OPPaymentStatusUnsuport;
                break;
            }
            default:
                break;
        }
        self.finishBlock(status);
        self.finishBlock=nil;
    }
}
@end
