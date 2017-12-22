//
//  OPWeixinPayment.h
//  OpenPlatform
//
//  Created by supertext on 15/10/8.
//  Copyright © 2015年 icegent. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenPlatform/OPPlatformProtocol.h>
@class OPPaymentOrder;
@interface OPWeixinPayment : NSObject<OPPlatformPayment>
@property(nonatomic)BOOL debugEnable;
@end
