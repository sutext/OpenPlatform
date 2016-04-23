//
//  OPAlipayPayment.h
//  OpenPlatform
//
//  Created by supertext on 15/10/8.
//  Copyright © 2015年 icegent. All rights reserved.
//
#ifdef ALLOW_ALIPAY
#import <Foundation/Foundation.h>
@class OPPaymentOrder;
@class ETDecryptor;
@interface OPAlipayPayment : NSObject
@property(nonatomic,strong)NSString *appid;
@property(nonatomic,strong)NSString *partnerid;
@property(nonatomic,strong)NSString *appkey;
@property(nonatomic,strong)NSString *scheme;
@property(nonatomic,strong)NSString *sellerid;//支付宝账户名info@mding.org
@property(nonatomic,strong)ETDecryptor * signer;
-(void)handlePamentResut:(NSDictionary *)result;
-(void)payWithOrder:(OPPaymentOrder *)order completed:(void (^)(BOOL isok,OPPaymentOrder *order)) completedBlock;

@end
#endif