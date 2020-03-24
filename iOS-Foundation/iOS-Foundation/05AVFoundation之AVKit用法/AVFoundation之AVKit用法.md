##  AVKit用法


### MediaPlayer

定义了MPMoviePlayerController和MPMoviePlayerViewController两个类，提供简单的方法将完整的视频播放功能（播放、暂停、快进等功能）整合到应用程序中。
需要导入对应的库文件#import <MediaPlayer/MediaPlayer.h>。
iOS8.0以后可以不再使用这个库，iOS9.0之后已经彻底放弃这个库文件，另外在iOS8.0之后提供了更加灵活的AVKit与AVFoundation结合的方式播放视频。


### AVKit

iOS 8.0之后引入AVKit框架，相对于之前的MediaPlayer框架，更复杂也更加灵活强大。iOS9.0之后MediaPlayer将被遗弃，所以更要关注的是AVKit。
AVKit里包含的内容很少，通过查看头文件，可以看到：
#import <AVKit/AVError.h>
#import <AVKit/AVPictureInPictureController.h>
#import <AVKit/AVPlayerViewController.h>
#import <AVKit/AVRoutePickerView.h>
其中iOS8.0只有对应的AVPlayerViewController。

1、AVPlayerViewController
AVPlayerViewController是UIViewController的子类，用于展示并控制AVPlayer实例的播放。
最简单的创建视频播放方式：
"
//初始化viewcontroller
AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"mp4"];
//创建AVPlayer
AVPlayer *player = [[AVPlayer alloc] initWithURL:fileUrl];
//将Player赋值给AVPlayerViewController
playerVC.player = player;    
[self presentViewController:playerVC animated:YES completion:nil];
"
1）对应的一些关键属性
player(AVPlayer)：播放视图的资源媒体内容。
showsPlaybackControls(BOOL)：表示播放空间是否显示或隐藏，默认YES显示。
videoGravity(NSString)：设置视频资源与视图承载范围的适应情况。
readyForDisplay(BOOL)：通过观察这个值来确定视频内容是否已经准备好进行展示。
videoBounds(CGRect)：视频相对于图层的尺寸和位置
contentOverlayView(UIView)：只读，可以添加自定义view在视频与控件之间。
2）层级/结构
AVPlayerViewController -> AVPlay -> AVPlayItem -> AVAsset
3）为AVPlayerViewController提供资源的步骤
"
// 1 通过URL创建资源
AVAsset *asset = [AVAsset assetWithURL:fileUrl];
// 2 为资源创建playerItem
AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
/ /3 通过playerItem创建Player
AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
// 4 将player与playerViewController关联。
playerViewController.player = player;
// 最简单的方式，将以上四步简化为一步。但是对应的更多操作将会受到限制，根据实际情况处理。
// playerViewController.player = [AVPlayer playerWithURL:fileUrl];
"
关于AVPlayerViewController更多的高级用法，更多的是AVPlayer的用法，与AVPlayerItem、AVAsset相关密切。也就是与AVFoundation的联合使用。
