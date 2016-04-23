//
//  OPAlipayPayment.m
//  OpenPlatform
//
//  Created by supertext on 15/10/8.
//  Copyright © 2015年 icegent. All rights reserved.
//
#ifdef ALLOW_ALIPAY
#import "OPAlipayPayment.h"
#import "OPPaymentOrder.h"
#import <AlipaySDK/AlipaySDK.h>
#import <EasyTools/EasyTools.h>
@interface OPAlipayPayment()
@property(nonatomic,copy)void (^completedBlock)(BOOL, OPPaymentOrder *);
@property(nonatomic,strong)OPPaymentOrder *payingOrder;
@property(nonatomic,strong)NSArray *orderKeys;
@end
@implementation OPAlipayPayment
-(NSArray *)orderKeys
{
    if (!_orderKeys)
    {
        self.orderKeys=@[@"partner"         ,@"seller_id",
                         @"out_trade_no"    ,@"subject",
                         @"body"            ,@"total_fee",
                         @"notify_url"      ,@"service",
                         @"payment_type"    ,@"_input_charset",
                         @"it_b_pay"        ,@"show_url",
                         @"sign_date"       ,@"app_id",];
    }
    return _orderKeys;
}
-(void)payWithOrder:(OPPaymentOrder *)order completed:(void (^)(BOOL, OPPaymentOrder *))completedBlock
{
    self.completedBlock = completedBlock;
    self.payingOrder = order;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:order.notifyurl           forKey:@"notify_url"];
    [params setValue:order.subject             forKey:@"subject"];
    [params setValue:order.productdesc         forKey:@"body"];
    [params setValue:order.amount              forKey:@"total_fee"];
    [params setValue:order.tradenumber         forKey:@"out_trade_no"];
    [params setValue:self.partnerid            forKey:@"partner"];
    [params setValue:self.sellerid             forKey:@"seller_id"];
    [params setValue:@"mobile.securitypay.pay" forKey:@"service"];
    [params setValue:@"1"                      forKey:@"payment_type"];
    [params setValue:@"utf-8"                  forKey:@"_input_charset"];
    [params setValue:@"30m"                    forKey:@"it_b_pay"];
    [params setValue:@"m.alipay.com"           forKey:@"show_url"];
    NSString *orderString = [self formatParams:params];
    NSString *signedString = [[[self.signer signatureMessage:orderString] base64EncodedStringWithOptions:0] ETURLEncodedString];
    NSString *result  = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",orderString, signedString, @"RSA"];
    [[AlipaySDK defaultService] payOrder:result fromScheme:self.scheme callback:^(NSDictionary *resultDic)
    {
        [self handlePamentResut:resultDic];
    }];
}
- (NSString *)formatParams:(NSDictionary *)params;
{
    NSMutableString * discription = [NSMutableString string];
    [self.orderKeys enumerateObjectsUsingBlock:^(NSString * key, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *value = [params objectForKey:key];
        if (value) {
            if (idx==0) {
                [discription appendFormat:@"%@=\"%@\"",key,value];
            }
            else
            {
                [discription appendFormat:@"&%@=\"%@\"",key,value];
            }
        }
    }];
    return discription;
}
-(void)handlePamentResut:(NSDictionary *)result
{
    BOOL isok = NO;
    if ([[result objectForKey:@"resultStatus"] doubleValue] == 9000) {
        NSString *resultSting = [result objectForKey:@"result"];
        if ([resultSting containsString:@"success=\"true\""]) {
            isok = YES;
        }
    }
    if (self.completedBlock) {
        self.completedBlock(isok,self.payingOrder);
        self.completedBlock = nil;
    }
}

@end
#endif