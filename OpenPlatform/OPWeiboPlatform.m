//
//  OPWeiboPlatform.m
//  OpenPlatform
//
//  Created by supertext on 15/10/11.
//  Copyright © 2015年 icegent. All rights reserved.
//
#ifdef ALLOW_WEIBO
#import "OPWeiboPlatform.h"
#import "OPOpenPlatform.h"
#import "OPShareMedia.h"
@interface OPWeiboPlatform()
@property(nonatomic,copy)void (^shareComplete)(NSInteger);
@end

@implementation OPWeiboPlatform
#pragma mark WBHttpRequestDelegate methods
-(void)shareWithMedia:(OPShareMedia *)media redirectURI:(NSString *)redirectURI completed:(void (^)(NSInteger))completedBlock
{
    if (![WeiboSDK isWeiboAppInstalled]) {
        if (completedBlock) {
            completedBlock(OPPlatformErrorNotInstall);
        }
        return;
    }
    if (![WeiboSDK isCanShareInWeiboAPP]) {
        if (completedBlock) {
            completedBlock(OPPlatformErrorUnsuport);
        }
        return;
    }
    WBMessageObject *message=[WBMessageObject message];
    message.text=media.title;
    
    WBWebpageObject *webpage = [WBWebpageObject object];
    webpage.objectID = @"identifier1";
    webpage.title = media.title;
    webpage.description = media.content;
    webpage.thumbnailData = UIImageJPEGRepresentation(media.image, 0.1);
    webpage.webpageUrl = media.linkURL;
    message.mediaObject = webpage;
    
    WBAuthorizeRequest *auth=[WBAuthorizeRequest request];
    auth.redirectURI=redirectURI;
    NSString *touken=nil;
//    if (kNCUserEntity&&self.loginPlatform==NCOpenLoginPlatformSN) {
//        touken=kNCUserEntity.tokenid;
//    }
//    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:auth access_token:touken];
    if ([WeiboSDK sendRequest:request]) {
        self.shareComplete=completedBlock;
    }
    else
    {
        if (completedBlock) {
            completedBlock(OPPlatformErrorException);
        }
    }

}
- (void)request:(WBHttpRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    
}
- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error
{
//    if (self.loginPlatform==NCOpenLoginPlatformSN&&self.loginComplete) {
//        self.loginComplete(NCOpenLoginPlatformSN,nil,nil,NCOpenErrorTypeNetwork);
//        self.loginComplete=nil;
//    }
    
}

- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result
{
    
}

- (void)request:(WBHttpRequest *)request didFinishLoadingWithDataResult:(NSData *)data
{
//    NSError *error=nil;
//    NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
//    if (!error&&[dic isKindOfClass:[NSDictionary class]]) {
//        if (self.loginPlatform==NCOpenLoginPlatformSN&&self.loginComplete) {
//            NSString *hearurl=[dic objectForKey:@"avatar_large"]; //profile_image_url,中图50*50,avatar_large大图180*180 ,avatar_hd 高清原图
//            NSString *nickname=[dic objectForKey:@"screen_name"];
//            NSDictionary *userdic=@{
//                                    @"expires_in":[NSString stringWithFormat:@"%.0f",[self.sina.expirationDate timeIntervalSince1970]*1000],
//                                    @"head":hearurl,
//                                    @"nickname":nickname,
//                                    @"access_token":self.sina.accessToken
//                                    };
//            self.loginComplete(NCOpenLoginPlatformSN,self.sina.userID,userdic,NCOpenErrorTypeSucceed);
//            self.loginComplete=nil;
//        }
//    }
//    else
//    {
//        if (self.loginPlatform==NCOpenLoginPlatformSN&&self.loginComplete) {
//            self.loginComplete(NCOpenLoginPlatformSN,nil,nil,NCOpenErrorTypeUnknown);
//            self.loginComplete=nil;
//        }
//    }
}
#pragma mark WeiboSDKDelegate methods
-(void)getSinaUserInfo:(WBAuthorizeResponse *)response
{
//    self.sina=response;
//    [WBHttpRequest requestWithAccessToken:response.accessToken
//                                      url:@"https://api.weibo.com/2/users/show.json"
//                               httpMethod:@"GET"
//                                   params:@{@"uid":response.userID}
//                                 delegate:self
//                                  withTag:nil];
}
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
//    if ([response isKindOfClass:[WBAuthorizeResponse class]])
//    {
//        WBAuthorizeResponse *authRespons=(WBAuthorizeResponse *)response;
//        if (authRespons.statusCode==WeiboSDKResponseStatusCodeSuccess&&authRespons.accessToken.length) {
//            [self getSinaUserInfo:authRespons];
//        }
//        else
//        {
//            if (self.loginPlatform==NCOpenLoginPlatformSN&&self.loginComplete) {
//                NCOpenErrorType errorType=NCOpenErrorTypeUnknown;
//                switch (authRespons.statusCode) {
//                    case WeiboSDKResponseStatusCodeUserCancel:
//                        errorType=NCOpenErrorTypeCancel;
//                        break;
//                    case WeiboSDKResponseStatusCodeSentFail:
//                        errorType=NCOpenErrorTypeNetwork;
//                        break;
//                    case WeiboSDKResponseStatusCodeAuthDeny:
//                        errorType=NCOpenErrorTypeRefuse;
//                        break;
//                    default:
//                        break;
//                }
//                self.loginComplete(NCOpenLoginPlatformSN,nil,nil,errorType);
//                self.loginComplete=nil;
//            }
//        }
//    }
//    else
    
    if([response isKindOfClass:[WBSendMessageToWeiboResponse class]])
    {
        if (self.shareComplete) {
            OPPlatformError type=OPPlatformErrorUnknown;
            WBSendMessageToWeiboResponse *msgresp=(WBSendMessageToWeiboResponse *)response;
            switch (msgresp.statusCode)
            {
                case    WeiboSDKResponseStatusCodeSuccess           :
                {
                    type=OPPlatformErrorSucceed;
                    break;
                }
                case    WeiboSDKResponseStatusCodeSentFail     :
                {
                    type=OPPlatformErrorUnknown;
                    break;
                }
                case    WeiboSDKResponseStatusCodeUserCancel :
                case    WeiboSDKResponseStatusCodeUserCancelInstall   :
                {
                    type=OPPlatformErrorCancel;
                    break;
                }
                case    WeiboSDKResponseStatusCodeAuthDeny   :
                {
                    type=OPPlatformErrorRefuse;
                    break;
                }
                case    WeiboSDKResponseStatusCodeShareInSDKFailed  :
                case    WeiboSDKResponseStatusCodeUnsupport  :
                {
                    type=OPPlatformErrorUnsuport;
                    break;
                }
                    break;
                default:
                    break;
            }
            self.shareComplete(type);
            self.shareComplete=nil;
        }
    }
}


@end
#endif