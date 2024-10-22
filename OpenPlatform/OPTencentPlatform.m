//
//  OPTencentPlatform.m
//  OpenPlatform
//
//  Created by supertext on 15/10/11.
//  Copyright © 2015年 icegent. All rights reserved.
//

#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "OPTencentPlatform.h"
#import "OPOpenPlatform.h"
#import "OPShareMedia.h"
@interface OPTencentPlatform()<TencentSessionDelegate,QQApiInterfaceDelegate>
@property(nonatomic,copy)void (^shareComplete)(NSInteger);
@property(nonatomic,copy)void (^authComplete)(NSInteger,NSString *);
@property(nonatomic,strong)TencentOAuth * tencent;
@end
@implementation OPTencentPlatform

- (instancetype)initWithAppid:(NSString *)appid appkey:(NSString *)appkey
{
    self = [super init];
    if (self) {
        self.tencent = [[TencentOAuth alloc] initWithAppId:appid andDelegate:self];
        self.appkey = appkey;
    }
    return self;
}
-(void)authCompleted:(void (^)(NSInteger, NSString *))completedBlock
{
//    if (![QQApiInterface isQQInstalled]) {
//        if (completedBlock) {
//            completedBlock(OPPlatformErrorNotInstall,nil);
//        }
//        return;
//    }
//    if (![QQApiInterface isQQSupportApi]) {
//        if (completedBlock) {
//            completedBlock(OPPlatformErrorUnsuport,nil);
//        }
//        return;
//    }
    NSArray* permissions = [NSArray arrayWithObjects:
                            kOPEN_PERMISSION_GET_USER_INFO,
                            kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                            kOPEN_PERMISSION_ADD_ALBUM,
                            kOPEN_PERMISSION_ADD_ONE_BLOG,
                            kOPEN_PERMISSION_ADD_SHARE,
                            kOPEN_PERMISSION_ADD_TOPIC,
                            kOPEN_PERMISSION_CHECK_PAGE_FANS,
                            kOPEN_PERMISSION_GET_INFO,
                            kOPEN_PERMISSION_GET_OTHER_INFO,
                            kOPEN_PERMISSION_LIST_ALBUM,
                            kOPEN_PERMISSION_UPLOAD_PIC,
                            kOPEN_PERMISSION_GET_VIP_INFO,
                            kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                            nil];
    self.authComplete = completedBlock;
    [self.tencent authorize:permissions];
}
-(NSString *)installURL{
    return QQApiInterface.getQQInstallUrl;
}
-(BOOL)isInstalled{
    return [QQApiInterface isQQInstalled];
}
-(BOOL)handleOpenURL:(NSURL *)url
{
    return [TencentOAuth HandleOpenURL:url];
}
-(BOOL)open{
    return [QQApiInterface openQQ];
}
-(BOOL)handelOpenURL:(NSURL *)openURL{
    if([openURL.scheme hasPrefix:@"tencent"])
    {
        return [TencentOAuth HandleOpenURL:openURL];
    }
    if ([openURL.scheme hasPrefix:@"QQ"])
    {
        return [QQApiInterface handleOpenURL:openURL delegate:self];
    }
    return NO;
}
-(void)shareWithMedia:(OPShareObject *)media isChart:(BOOL)isChart completed:(void (^)(NSInteger))completedBlock
{
    if (![QQApiInterface isQQInstalled]) {
        if (completedBlock) {
            completedBlock(OPPlatformErrorNotInstall);
        }
        return;
    }
    if (![QQApiInterface isQQSupportApi]) {
        if (completedBlock) {
            completedBlock(OPPlatformErrorUnsuport);
        }
        return;
    }
    QQApiObject * object;
    if ([media isKindOfClass:[OPShareWebpage class]]){
        OPShareWebpage *share = (OPShareWebpage *)media;
        QQApiURLObject *urlobj=[[QQApiURLObject alloc]
                                initWithURL:[NSURL URLWithString:share.weburl]
                                title:media.title
                                description:media.content
                                previewImageData:media.thumbData
                                targetContentType:QQApiURLTargetTypeNews];
        object = urlobj;
    }else if([media isKindOfClass:[OPShareMusic class]]) {
        OPShareMusic *share = (OPShareMusic *)media;
        QQApiAudioObject *music=[[QQApiAudioObject alloc]
                                initWithURL:[NSURL URLWithString:share.weburl]
                                title:media.title
                                description:media.content
                                previewImageData:media.thumbData
                                targetContentType:QQApiURLTargetTypeAudio];
        music.flashURL = [NSURL URLWithString:share.dataURL];
        object = music;
    }else if([media isKindOfClass:[OPShareImage class]]){
        OPShareImage *share = (OPShareImage *)media;
        QQApiImageObject *image = [[QQApiImageObject alloc]
                                   initWithData:share.imageData
                                   previewImageData:share.thumbData
                                   title:share.title
                                   description:share.content];
        object = image;
    }
    
    QQApiSendResultCode code=0;
    if (isChart) {
        code= [QQApiInterface sendReq:[SendMessageToQQReq reqWithContent:object]];
    }
    else
    {
        code=[QQApiInterface SendReqToQZone:[SendMessageToQQReq reqWithContent:object]];
    }
    if (code==EQQAPIAPPSHAREASYNC||code==EQQAPISENDSUCESS) {
        self.shareComplete=completedBlock;
    }
    else
    {
        if (completedBlock) {
            completedBlock([self erroTypeWithResult:code]);
        }
        return;
    }
}
- (OPPlatformError)erroTypeWithResult:(QQApiSendResultCode)sendResult
{
    OPPlatformError result=OPPlatformErrorUnknown;
    switch (sendResult)
    {
        case EQQAPIQQNOTINSTALLED:
        {
            result=OPPlatformErrorNotInstall;
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            result=OPPlatformErrorUnsuport;
            break;
        }
        case EQQAPISENDFAILD:
        {
            result=OPPlatformErrorUnknown;
            break;
        }
        case EQQAPIAPPNOTREGISTED:
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            result=OPPlatformErrorException;
            break;
        }
        default:
        {
            break;
        }
    }
    return result;
}

#pragma mark - QQApiInterfaceDelegate
- (void)onReq:(QQBaseReq *)req
{
}
- (void)onResp:(QQBaseResp *)resp
{
    if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
        if (self.shareComplete) {
            OPPlatformError type=OPPlatformErrorUnknown;
            if ([resp.result isEqualToString:@"0"]) {
                type=OPPlatformErrorSucceed;
            }
            else if ([resp.result isEqualToString:@"-4"])
            {
                type=OPPlatformErrorCancel;
            }
            self.shareComplete(type);
            self.shareComplete=nil;
        }
    }
}


- (void)isOnlineResponse:(NSDictionary *)response
{
    
}
#pragma mark QQ methods
- (void)tencentDidLogin
{
    if (self.tencent.accessToken && 0!= [self.tencent.accessToken length])
        
    {
        if (self.authComplete) {
            self.authComplete(OPPlatformErrorSucceed, self.tencent.accessToken);
            self.authComplete=nil;
        }
    }
    else
    {
        if (self.authComplete) {
            self.authComplete(OPPlatformErrorException, nil);
            self.authComplete=nil;
        }
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    if (self.authComplete) {
        OPPlatformError error = OPPlatformErrorException;
        if (cancelled) {
            error = OPPlatformErrorCancel;
        }
        self.authComplete(error, nil);
        self.authComplete=nil;
    }
}

- (void)tencentDidNotNetWork
{
    if (self.authComplete) {
        self.authComplete(OPPlatformErrorNetwork, nil);
    }
    self.authComplete=nil;
}

- (void)tencentOAuth:(TencentOAuth *)tencentOAuth doCloseViewController:(UIViewController *)viewController
{
    
}
- (void)getUserInfoResponse:(APIResponse*) response
{
}

@end
