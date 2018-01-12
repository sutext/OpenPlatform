//
//  OPAlipayPayment.m
//  OpenPlatform
//
//  Created by supertext on 15/10/8.
//  Copyright © 2015年 icegent. All rights reserved.
//
#import "OPAlipayPayment.h"
#import <AlipaySDK/AlipaySDK.h>
@interface OPAlipayPayment()
@property(nonatomic,copy)void (^paymentBlock)(OPPaymentStatus);
@property(nonatomic,copy)void (^authBlock)(OPPlatformError,NSString *);
@property(nonatomic,strong)NSArray *orderKeys;
@end
@implementation OPAlipayPayment
- (instancetype)initWithAppid:(NSString *)appid schema:(NSString *)schema
{
    self = [super init];
    if (self) {
        self.appid = appid;
        self.scheme = schema;
    }
    return self;
}
-(void)paymentWithInfo:(OPPaymentInfo *)info finishBlock:(void (^)(OPPaymentStatus))finishBlock{
    [[AlipaySDK defaultService] payOrder:info.sign fromScheme:self.scheme callback:^(NSDictionary *resultDic) {
        [self handlePamentResut:resultDic];
    }];
    self.paymentBlock = finishBlock;
}

-(void)authWithInfo:(NSString *)info finishBlock:(void (^)(OPPlatformError,NSString * _Nullable))finishBlock{
    
    [[AlipaySDK defaultService] auth_V2WithInfo:info fromScheme:self.scheme callback:^(NSDictionary *resultDic) {
        [self handleAuthResult:resultDic];
    }];
    self.authBlock = finishBlock;
}
-(BOOL)handelOpenURL:(NSURL *)openURL
{
    [[AlipaySDK defaultService] processOrderWithPaymentResult:openURL standbyCallback:^(NSDictionary *resultDic) {
        [self handlePamentResut:resultDic];
    }];
    [[AlipaySDK defaultService] processAuth_V2Result:openURL standbyCallback:^(NSDictionary *resultDic) {
        [self handleAuthResult:resultDic];
    }];
    return YES;
}
-(BOOL)isInstalled{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"alipay://"]];
}
-(NSString *)installURL{
    return  nil;
}
-(BOOL)open{
    return [UIApplication.sharedApplication openURL:[NSURL URLWithString:@"alipay://"]];
}
-(void)authCompleted:(void (^)(NSInteger, NSString *))completedBlock{

}
-(void)handleAuthResult:(NSDictionary *)resultDic{
    if (self.debugEnable) {
        NSLog(@"result = %@",resultDic);
    }
    if (self.authBlock){
        NSInteger code = [[resultDic objectForKey:@"resultStatus"] integerValue];
        NSString *authCode = nil;
        OPPlatformError error = OPPlatformErrorUnknown;
        switch (code) {
            case 9000:{
                error = OPPlatformErrorSucceed;
                NSString *result = resultDic[@"result"];
                if (result.length>0) {
                    NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                    for (NSString *subResult in resultArr) {
                        if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                            authCode = [subResult substringFromIndex:10];
                            break;
                        }
                    }
                }
                break;
            }
            case 4000:{
                error = OPPlatformErrorException;
                break;
            }
            case 6001:{
                error = OPPlatformErrorCancel;
                break;
            }
            case 6000:{
                error = OPPlatformErrorNetwork;
                break;
            }
            default:
                break;
        }
        // 解析 auth code
        self.authBlock(error,authCode);
        self.authBlock = nil;
    }
}
-(void)handlePamentResut:(NSDictionary *)result
{
    if (self.debugEnable) {
        NSLog(@"result = %@",result);
    }
    if (self.paymentBlock){
        NSInteger code = [[result objectForKey:@"resultStatus"] integerValue];
        OPPaymentStatus status = OPPaymentStatusOther;
        switch (code) {
            case 9000:{
                status = OPPaymentStatusSucceed;
                break;
            }
            case 8000:{
                status = OPPaymentStatusProcessing;
                break;
            }
            case 4000:{
                status = OPPaymentStatusFailed;
                break;
            }
            case 6001:{
                status  = OPPaymentStatusCancel;
                break;
            }
            case 6002:{
                status = OPPaymentStatusNetwork;
                break;
            }
            case 6004:{
                status = OPPaymentStatusUnknown;
                break;
            }
            default:
                break;
        }
        self.paymentBlock(status);
        self.paymentBlock = nil;
    }
}
@end
