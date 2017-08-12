//
//  NotificationViewController.m
//  Notification
//
//  Created by 王盛魁 on 2017/8/12.
//  Copyright © 2017年 WangShengKui. All rights reserved.
//

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

@interface NotificationViewController () <UNNotificationContentExtension>

@property IBOutlet UILabel *label;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any required interface initialization here.
}
// 只要你收到通知，并且保证categoryIdentifier的设置，跟info.plist里面设置的一样，你就会调用这个方法。
// 注意：一个会话的多个通知，每个通知收到时，都可以调用这个方法。
- (void)didReceiveNotification:(UNNotification *)notification {
    self.label.text = notification.request.content.body;
    // 这个方法，可以给自己的控件赋值啊，调整frame啊等等，我在这里打印出来了通知的内容，供大家使用。
    NSDictionary *dict =  notification.request.content.userInfo;
    // 这里可以把打印的所有东西拿出来
    NSLog(@"%@",dict);
    
    /****************************打印的信息是************
     aps =     {
     alert = "This is some fancy message.";
     badge = 1;
     from = "hello word";
     imageAbsoluteString = "http://upload.univs.cn/2012/0104/1325645511371.jpg";
     "mutable-content" = 1;
     sound = default;
     };
     *******************************************/
    // 不同的分类标识符
    NSString *categoryId = notification.request.content.categoryIdentifier;
}

- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response completionHandler:(void (^)(UNNotificationContentExtensionResponseOption option))completion{
    
}
// 返回 默认的button样式
- (UNNotificationContentExtensionMediaPlayPauseButtonType)mediaPlayPauseButtonType{
    return UNNotificationContentExtensionMediaPlayPauseButtonTypeDefault;
}
// 返回 button的frame
- (CGRect)mediaPlayPauseButtonFrame{
    return CGRectMake(100, 100, 100, 100);
}
// 返回 button的颜色
- (UIColor *)mediaPlayPauseButtonTintColor{
    return [UIColor blueColor];
}
// 点击 button的点击事件
- (void)mediaPlay{
    NSLog(@">>func mediaPlay,开始播放");
    // 点击播放按钮后，4s后暂停播放
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 控制暂停
        [self.extensionContext mediaPlayingPaused];
    });
    
    
}
- (void)mediaPause{
    NSLog(@">>func mediaPause，暂停播放");
    // 点击暂停按钮，10s后开始播放
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 控制播放
        [self.extensionContext mediaPlayingStarted];
    });
}
@end
