//
//  OPShareMedia.m
//  OpenPlatform
//
//  Created by supertext on 15/10/6.
//  Copyright © 2015年 icegent. All rights reserved.
//

#import "OPShareMedia.h"

@implementation OPShareObject
-(NSData *)thumbData{
    if (self.thumb) {
        return UIImageJPEGRepresentation(self.thumb, 0.5);
    }
    return  nil;
}
@end

@implementation OPShareWebpage

@end
@implementation OPShareMusic

@end
@implementation OPShareImage
-(NSData *)imageData{
    if (self.image) {
        return UIImageJPEGRepresentation(self.image, 1);
    }
    return  nil;
}
@end
