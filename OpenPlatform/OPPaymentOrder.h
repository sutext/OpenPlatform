//
//  OPPaymentOrder.h
//  OpenPlatform
//
//  Created by supertext on 15/10/8.
//  Copyright © 2015年 icegent. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface OPPaymentOrder : NSObject

@property(nonatomic,strong,nullable)NSString *tradenumber;
@property(nonatomic,strong,nullable)NSString *productdesc;
@property(nonatomic,strong,nullable)NSString *amount;
@property(nonatomic,strong,nullable)NSString *notifyurl;
@property(nonatomic,strong,nullable)NSString *subject;

@end
NS_ASSUME_NONNULL_END