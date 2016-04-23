//
//  OPShareMedia.h
//  OpenPlatform
//
//  Created by supertext on 15/10/6.
//  Copyright © 2015年 icegent. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface OPShareMedia : NSObject
@property(nonatomic,strong,nullable)NSString *title;
@property(nonatomic,strong,nullable)NSString *content;
@property(nonatomic,strong,nullable)NSString *linkURL;
@property(nonatomic,strong,nullable)UIImage  *image;
@end
NS_ASSUME_NONNULL_END