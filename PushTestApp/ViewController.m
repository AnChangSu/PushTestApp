//
//  ViewController.m
//  PushTestApp
//
//  Created by 王盛魁 on 2017/8/9.
//  Copyright © 2017年 WangShengKui. All rights reserved.
//

#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <CoreLocation/CoreLocation.h>
#import<MobileCoreServices/MobileCoreServices.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0){
        [self creatLocalPushIOS10];
    }else{
        [self creatLocalPush];
    }
}
#pragma mark - 创建本地推送 ios10 之前
- (void)creatLocalPush{
    UILocalNotification *localNotifi = [[UILocalNotification alloc]init];
    // 设置触发时间
    localNotifi.fireDate = [NSDate dateWithTimeIntervalSinceNow:3];
    // 设置时区  以当前手机运行的时区为准
    localNotifi.timeZone = [NSTimeZone defaultTimeZone];
    // 设置推送 显示的内容
    localNotifi.alertTitle = @"推送标题";
    localNotifi.alertBody = @"本地推送内容";
    localNotifi.alertAction = @"alert提示框按钮文本";
    //是否显示额外的按钮，为no时alertAction消失
    localNotifi.hasAction = YES;
    // 设置 icon小红点个数
    localNotifi.applicationIconBadgeNumber = 1;
    // 设置是否重复  重复最小时间间隔为秒，但最好是分钟
    // 不设置此属性，则默认不重复
    localNotifi.repeatInterval =  NSCalendarUnitMinute;
    // 设置推送的声音
    // 通知的声音默认是iOS系统自带的声音，当然也支持自定义，但是自定义必须是固定格式的音频文件，不支持mp3，最常用的是cef/pcm/ma4/alaw格式的音频文件，并且播放时间不能长于30秒，如果长于30秒，将会被系统时间所代替，音频文件必须放在工程文件当中([NSBundle mainBundle])
    localNotifi.soundName = UILocalNotificationDefaultSoundName;
    
    // 设置推送的区别符
    localNotifi.userInfo = @{@"name":@"loaclPushOne"};
    // 按照前面设置的计划 执行此通知
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotifi];
}
// 关闭本地推送
- (void)deleteLocalPush{
    // 获取该app上所有的本地推送
    NSArray *allLocalNotifi = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    // 取消特定的本地推送
    UILocalNotification *localNotifi  = nil;
    for (UILocalNotification *item in allLocalNotifi) {
        NSDictionary *userInfo = item.userInfo;
        if ([[userInfo objectForKey:@"name"] isEqualToString:@"loaclPushOne"]) {
            localNotifi = item;
            break;
        }
    }
    [[UIApplication sharedApplication] cancelLocalNotification:localNotifi];
    
    // 取消所有的本地推送
    [[UIApplication sharedApplication]  cancelAllLocalNotifications];
    
}
#pragma mark - 创建本地推送 ios10之后
- (void)creatLocalPushIOS10{
    // 创建本地通知也需要在appdelegate中心进行注册
    // 1.创建通知内容
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"本地通知标题";
    content.subtitle = @"本地通知副标题";
    content.body = @"本地通知内容";
    content.badge = @1;
    NSError *error = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"imageName@2x" ofType:@"png"];
    // 2.设置通知附件内容
    NSMutableDictionary *optionsDict = [NSMutableDictionary dictionary];
    // 一个包含描述文件的类型统一类型标识符（UTI）一个NSString。如果不提供该键，附件的文件扩展名来确定其类型，常用的类型标识符有 kUTTypeImage,kUTTypeJPEG2000,kUTTypeTIFF,kUTTypePICT,kUTTypeGIF ,kUTTypePNG,kUTTypeQuickTimeImage等。
    
    // 需要导入框架 #import<MobileCoreServices/MobileCoreServices.h>
    optionsDict[UNNotificationAttachmentOptionsTypeHintKey] = (__bridge id _Nullable)(kUTTypeImage);
    // 是否隐藏缩略图
    optionsDict[UNNotificationAttachmentOptionsThumbnailHiddenKey] = @YES;
    // 剪切缩略图
    optionsDict[UNNotificationAttachmentOptionsThumbnailClippingRectKey] = (__bridge id _Nullable)((CGRectCreateDictionaryRepresentation(CGRectMake(0.25, 0.25, 0.5 ,0.5))));
    // 如果附件是影片，则以第几秒作为缩略图
    optionsDict[UNNotificationAttachmentOptionsThumbnailTimeKey] = @1;
    // optionsDict如果不需要，可以不设置，直接传nil即可
    UNNotificationAttachment *att = [UNNotificationAttachment attachmentWithIdentifier:@"identifier" URL:[NSURL fileURLWithPath:path] options:optionsDict error:&error];
    if (error) {
        NSLog(@"attachment error %@", error);
    }
    content.attachments = @[att];
    content.launchImageName = @"imageName@2x";
    // 2.设置声音
    UNNotificationSound *sound = [UNNotificationSound defaultSound];
    content.sound = sound;
    // 3.触发模式 多久触发，是否重复
     // 3.1 按秒
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
     // 3.2 按日期
//    // 周二早上 9：00 上班
//    NSDateComponents *components = [[NSDateComponents alloc] init];
//    // 注意，weekday是从周日开始的计数的
//    components.weekday = 3;
//    components.hour = 9;
//    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
    // 3.3 按地理位置
    // 一到某个经纬度就通知，判断包含某一点么
    // 不建议使用！！！！！！CLRegion *region = [[CLRegion alloc] init];
    
//    CLCircularRegion *circlarRegin = [[CLCircularRegion alloc] init];
//    // 经纬度
//    CLLocationDegrees latitudeDegrees = 123.00; // 维度
//    CLLocationDegrees longitudeDegrees = 123.00; // 经度
//
//    [circlarRegin containsCoordinate:CLLocationCoordinate2DMake(latitudeDegrees, longitudeDegrees)];
//    UNLocationNotificationTrigger *trigger = [UNLocationNotificationTrigger triggerWithRegion:circlarRegin repeats:NO];

    
    // 4.设置UNNotificationRequest
    NSString *requestIdentifer = @"TestRequest";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifer content:content trigger:trigger];
    
    //5.把通知加到UNUserNotificationCenter, 到指定触发点会被触发
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
