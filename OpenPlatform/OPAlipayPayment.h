//
//  OPAlipayPayment.h
//  OpenPlatform
//
//  Created by supertext on 15/10/8.
//  Copyright © 2015年 icegent. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import <OpenPlatform/OPPlatformProtocol.h>
@interface OPAlipayPayment : NSObject<OPAlipayProtocol>
-(instancetype)initWithAppid:(NSString *)appid schema:(NSString *)schema;
@property(nonatomic,strong)NSString *scheme;
@property(nonatomic,strong)NSString *appid;
@property(nonatomic)BOOL debugEnable;
@end

