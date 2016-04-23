//
//  OPPaymentOrder.m
//  OpenPlatform
//
//  Created by supertext on 15/10/8.
//  Copyright © 2015年 icegent. All rights reserved.
//

#import "OPPaymentOrder.h"

@implementation OPPaymentOrder
- (NSString *)description
{
    return [NSString stringWithFormat:@"tradenumber:%@\nproductdesc:%@\namount:%@\nnotifyurl:%@\nsubject:%@\n", self.tradenumber,self.productdesc,self.amount,self.notifyurl,self.subject];
}
@end
