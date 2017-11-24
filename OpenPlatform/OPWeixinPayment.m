//
//  OPWeixinPayment.m
//  OpenPlatform
//
//  Created by supertext on 15/10/8.
//  Copyright © 2015年 icegent. All rights reserved.
//

#import <CommonCrypto/CommonCrypto.h>
#import "OPWeixinPayment.h"
#import "OPPaymentOrder.h"
@interface OPWeixinPayment()<NSXMLParserDelegate>
@property(nonatomic,strong)OPPaymentOrder *payingOrder;
@property(nonatomic,copy)void (^completedBlock)(BOOL, OPPaymentOrder *);
@property(nonatomic,strong)NSString *prepayid;
@property(nonatomic,strong)NSString *dynamicDomname;
@end
@implementation OPWeixinPayment
-(void)payWithOrder:(OPPaymentOrder *)order completed:(void (^)(BOOL, OPPaymentOrder *))completedBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:order.notifyurl            forKey:@"notify_url"];
    [params setValue:order.subject              forKey:@"body"];
    [params setValue:order.productdesc          forKey:@"attach"];
    [params setValue:[NSString stringWithFormat:@"%.0f",[order.amount doubleValue]*100]              forKey:@"total_fee"];
    [params setValue:order.tradenumber          forKey:@"out_trade_no"];
    [params setValue: self.appid                forKey:@"appid"];       //开放平台appid
    [params setValue: self.partnerid            forKey:@"mch_id"];      //商户号
    [params setValue: @"APP-001"                forKey:@"device_info"]; //支付设备号或门店号
    [params setValue: @"APP"                    forKey:@"trade_type"];  //支付类型，固定为APP
    [params setValue: @"196.168.1.1"            forKey:@"spbill_create_ip"];
    [self prepayWithParams:params];
    PayReq *req = [self createRequest];
    if (!req) {
        if (completedBlock) {
            completedBlock(NO,order);
            self.completedBlock=nil;
        }
    }
    else
    {
        self.payingOrder=order;
        self.completedBlock=completedBlock;
        [WXApi sendReq:req];
    }
}
-(NSString*) createMd5Sign:(NSMutableDictionary*)dict
{
    NSMutableString *contentString  =[NSMutableString string];
    NSArray *keys = [dict allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    for (NSString *categoryId in sortedArray) {
        if (   ![[dict objectForKey:categoryId] isEqualToString:@""]
            && ![categoryId isEqualToString:@"sign"]
            && ![categoryId isEqualToString:@"key"]
            )
        {
            [contentString appendFormat:@"%@=%@&", categoryId, [dict objectForKey:categoryId]];
        }
    }
    [contentString appendFormat:@"key=%@", self.signkey];
    NSString *md5Sign =[self md5:contentString];
    return md5Sign;
}
-(NSString *)genPackage:(NSMutableDictionary*)packageParams
{
    NSString *sign;
    NSMutableString *reqPars=[NSMutableString string];
    sign        = [self createMd5Sign:packageParams];
    NSArray *keys = [packageParams allKeys];
    [reqPars appendString:@"<xml>\n"];
    for (NSString *categoryId in keys) {
        [reqPars appendFormat:@"<%@>%@</%@>\n", categoryId, [packageParams objectForKey:categoryId],categoryId];
    }
    [reqPars appendFormat:@"<sign>%@</sign>\n</xml>", sign];
    return [NSString stringWithString:reqPars];
}
-(void)prepayWithParams:(NSMutableDictionary *)params
{
    srand( (unsigned)time(0) );
    NSString *noncestr  = [NSString stringWithFormat:@"%d", rand()];
    [params setObject: noncestr          forKey:@"nonce_str"];   //随机串
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://api.mch.weixin.qq.com/pay/unifiedorder"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"UTF-8" forHTTPHeaderField:@"charset"];
    [request setHTTPBody:[[self genPackage:params] dataUsingEncoding:NSUTF8StringEncoding]];
    NSError *error;
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (self.debugEnable)
    {
        NSLog(@"the prepay respones info%@",[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding]);
    }
    NSXMLParser *paprser = [[NSXMLParser alloc] initWithData:response];
    paprser.delegate = self;
    [paprser parse];
}
-(PayReq *)createRequest
{
    if (![self.prepayid hasPrefix:@"wx"]) {
        return nil;
    }
    NSString    *package, *time_stamp, *nonce_str;
    time_t now;
    time(&now);
    time_stamp  = [NSString stringWithFormat:@"%ld", now];
    nonce_str	= [self md5:time_stamp];
    package         = @"Sign=WXPay";
    NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
    [signParams setObject: self.appid       forKey:@"appid"];
    [signParams setObject: nonce_str                forKey:@"noncestr"];
    [signParams setObject: package                  forKey:@"package"];
    [signParams setObject: self.partnerid   forKey:@"partnerid"];
    [signParams setObject: time_stamp               forKey:@"timestamp"];
    [signParams setObject: self.prepayid                 forKey:@"prepayid"];
    NSString *sign  = [self createMd5Sign:signParams];
    [signParams setObject: sign         forKey:@"sign"];
    PayReq* req             = [[PayReq alloc] init];
    req.openID              = self.appid;
    req.partnerId           = self.partnerid;
    req.prepayId            = self.prepayid;
    req.nonceStr            = nonce_str;
    req.timeStamp           = [time_stamp intValue];
    req.package             = package;
    req.sign                = sign;
    return req;
}
#pragma mark - - weixin call back
-(void) onResp:(BaseResp*)resp
{
    if (self.debugEnable)
    {
        NSLog(@"the paymen resp code=%d,error=%@",resp.errCode,resp.errStr);
    }
    BOOL isok = ([resp isKindOfClass:[PayResp class]]&&resp.errCode==WXSuccess);
    if (self.completedBlock)
    {
        self.completedBlock(isok,self.payingOrder);
        self.completedBlock=nil;
    }
}
#pragma mark NSXMLParser
-  (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
     attributes:(NSDictionary *)attributeDict
{
    self.dynamicDomname =elementName;
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if ([self.dynamicDomname isEqualToString:@"prepay_id"]) {
        self.prepayid=string;
        [parser abortParsing];
        self.dynamicDomname=nil;
    }
}
-(NSString *)md5:(NSString *) string
{
    const char *str = [string UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *result = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                        r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    return [result uppercaseString];
}
@end
