//
//  OPWeixinPayment.h
//  OpenPlatform
//
//  Created by supertext on 15/10/8.
//  Copyright © 2015年 icegent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
@class OPPaymentOrder;
@interface OPWeixinPayment : NSObject<WXApiDelegate>
@property(nonatomic,strong)NSString *appid;
@property(nonatomic,strong)NSString *partnerid;
@property(nonatomic,strong)NSString *signkey;
@property(nonatomic)BOOL debugEnable;
-(void)payWithOrder:(OPPaymentOrder *)order
          completed:(void (^)(BOOL isok,OPPaymentOrder *order)) completedBlock;
@end
