//
//  ViewController.m
//  PushTestApp
//
//  Created by 王盛魁 on 2017/8/9.
//  Copyright © 2017年 WangShengKui. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    [self creatLocalPush];
}
// 创建本地推送
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
