//
//  XZQVideoPlayerController.m
//  iOS-Foundation
//
//  Created by qhzc-iMac-02 on 2020/3/23.
//  Copyright © 2020 Xuzq. All rights reserved.
//

#import "XZQVideoPlayerController.h"

static const char *PlayerStatusContext;

@interface XZQVideoPlayerController ()

@property(nonatomic,strong) AVPlayer *player;

// 播放相关UI
@property(nonatomic,strong) UISlider *slider;
@property(nonatomic,strong) UILabel *time;
@property(nonatomic,strong) UIButton *playBtn;
@property(nonatomic,strong) UIButton *stopBtn;

@end

@implementation XZQVideoPlayerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createPlayUI];
    
    // 创建资源实例
    NSURL *videoUrl = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"mp4"];
    AVAsset *assert = [AVAsset assetWithURL:videoUrl];
    // 关联播放资源
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:assert];
    // 在将AVPlayerItem与AVPlayer关联之前添加status属性观察
    [self addObserver:self forKeyPath:@"status" options:0 context:&PlayerStatusContext];
    // 创建player
    self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    // 设置定期监听
    dispatch_queue_t quene = dispatch_get_main_queue();
    __weak typeof(self) weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 2) queue:quene usingBlock:^(CMTime time) {
        NSTimeInterval currentTime = CMTimeGetSeconds(time);
        NSTimeInterval durationTime = CMTimeGetSeconds(playerItem.duration);
        weakSelf.time.text = [NSString stringWithFormat:@"%.0f/%.0f", currentTime, durationTime];
        weakSelf.slider.maximumValue = durationTime;
        weakSelf.slider.value = currentTime;
    }];
    // 创建playerLayerf放资源内容
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    playerLayer.frame = CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width * 0.75);
    // 添加到界面
    [self.view.layer addSublayer:playerLayer];
    
    // 添加条目结束监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playOverNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
}

- (void)createPlayUI {
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 120 + [UIScreen mainScreen].bounds.size.width * 0.75, 160, 30)];
    [self.view addSubview:self.slider];
    
    self.time = [[UILabel alloc] initWithFrame:CGRectMake(200, 120 + [UIScreen mainScreen].bounds.size.width * 0.75, 120, 30)];
    self.time.textColor = [UIColor blackColor];
    self.time.text = @"0/0";
    self.time.font = [UIFont systemFontOfSize:13.0f];
    [self.view addSubview:self.time];
    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playBtn.frame = CGRectMake(180, 160 + [UIScreen mainScreen].bounds.size.width * 0.75, 60, 30);
    [self.playBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [self.playBtn setTitle:@"播放" forState:UIControlStateNormal];
    self.playBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [self.view addSubview:self.playBtn];
    [self.playBtn addTarget:self action:@selector(playClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.stopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.stopBtn.frame = CGRectMake(250, 160 + [UIScreen mainScreen].bounds.size.width * 0.75, 60, 30);
    [self.stopBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [self.stopBtn setTitle:@"停止" forState:UIControlStateNormal];
    self.stopBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [self.view addSubview:self.stopBtn];
    [self.stopBtn addTarget:self action:@selector(stopClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)playClick {
    if ([self.playBtn.titleLabel.text isEqualToString:@"播放"]) {
        [self.player play];
        [self.playBtn setTitle:@"暂停" forState:UIControlStateNormal];
    } else {
        [self.player pause];
        [self.playBtn setTitle:@"播放" forState:UIControlStateNormal];
    }
}

- (void)stopClick {
    [self.player pause];
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        // 播放结束后的一些操作，例如对UI的一些操作
        self.time.text = @"0/0";
        self.slider.value = 0.0f;
        [self.playBtn setTitle:@"播放" forState:UIControlStateNormal];
    }];
}

- (void)playOverNotification:(NSNotification *)notification {
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        // 播放结束后的一些操作，例如对UI的一些操作
        self.time.text = @"0/0";
        self.slider.value = 0.0f;
        [self.playBtn setTitle:@"播放" forState:UIControlStateNormal];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &PlayerStatusContext) {
        NSLog(@"status change");
        AVPlayerItem *item = (AVPlayerItem *)object;
        NSLog(@"status: %zd -- %zd", item.status, AVPlayerItemStatusReadyToPlay);
        if (item.status == AVPlayerItemStatusReadyToPlay) {
            [self.player play];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
