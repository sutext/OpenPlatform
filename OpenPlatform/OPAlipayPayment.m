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
@property(nonatomic,copy)void (^finishBlock)(OPPaymentStatus);
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
}
-(BOOL)handelOpenURL:(NSURL *)openURL
{
    [[AlipaySDK defaultService] processOrderWithPaymentResult:openURL standbyCallback:^(NSDictionary *resultDic) {
        [self handlePamentResut:resultDic];
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
-(void)handlePamentResut:(NSDictionary *)result
{
    if (self.debugEnable) {
        NSLog(@"result = %@",result);
    }
    if (self.finishBlock){
        NSInteger code = [[result objectForKey:@"resultStatus"] integerValue];
        OPPaymentStatus status = OPPaymentStatusUnknown;
        switch (code) {
            case 9000:{
                NSString *resultSting = [result objectForKey:@"result"];
                if ([resultSting containsString:@"success=\"true\""]) {
                    status = OPPaymentStatusSucceed;
                }
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
                status = OPPaymentStatusNetError;
                break;
            }
            default:
                break;
        }
        self.finishBlock(status);
        self.finishBlock = nil;
    }
}

@end
