//
//  OPAuthObject.h
//  OpenPlatform
//
//  Created by supertext on 15/10/7.
//  Copyright © 2015年 icegent. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface OPAuthObject : NSObject
@property(nonatomic,strong,nullable)NSString *openid;
@property(nonatomic,strong,nullable)NSString *unionid;
@property(nonatomic,strong,nullable)NSString *nickname;
@property(nonatomic,strong,nullable)NSString *avatar;
@property(nonatomic,strong,nullable)NSString *gender;
@property(nonatomic,strong,nullable)NSString *token;
@end
NS_ASSUME_NONNULL_END
