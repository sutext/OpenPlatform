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

@protocol OPShareObject<NSObject>
@property(nonatomic,strong,nullable)NSString *title;
@property(nonatomic,strong,nullable)NSString *content;
@property(nonatomic,strong,nullable)UIImage  *image;
@end

@interface OPShareWebpage:NSObject<OPShareObject>
@property(nonatomic,strong,nullable)NSString *title;
@property(nonatomic,strong,nullable)NSString *content;
@property(nonatomic,strong,nullable)UIImage  *image;
@property(nonatomic,strong,nullable)NSString *weburl;
@end

@interface OPShareMusic:NSObject<OPShareObject>
@property(nonatomic,strong,nullable)NSString *title;
@property(nonatomic,strong,nullable)NSString *content;
@property(nonatomic,strong,nullable)UIImage  *image;
@property(nonatomic,strong,nullable)NSString *lowbandDataURL;
@property(nonatomic,strong,nullable)NSString *lowbandURL;
@property(nonatomic,strong,nullable)NSString *dataURL;
@property(nonatomic,strong,nullable)NSString *webURL;
@end
NS_ASSUME_NONNULL_END
