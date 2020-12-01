//
//  XZQPlayAndRecordViewController.m
//  iOS-Foundation
//
//  Created by qhzc-iMac-02 on 2020/3/17.
//  Copyright © 2020 Xuzq. All rights reserved.
//

#import "XZQPlayAndRecordViewController.h"

@interface XZQPlayAndRecordViewController ()

// 播放音频
@property(nonatomic,strong) AVAudioPlayer *audioPlayer;
// 录制音频
@property(nonatomic,strong) AVAudioRecorder *audioRecorder;

@end

@implementation XZQPlayAndRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createPlayBth];
    // 获取本地音频
    NSURL *audioUrl = [[NSBundle mainBundle] URLForResource:@"把故事写成我们" withExtension:@"mp3"];
    [self initPlay:audioUrl];
    
    [self createRecordBtn];
    // 配置录音保存的文件
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"1.caf"];
    NSURL *recorderUrl = [NSURL fileURLWithPath:path];
    NSDictionary *settings = @{
        AVFormatIDKey: @(kAudioFormatAppleIMA4),  // 写入内容的音频格式
        AVSampleRateKey: @22500.0f,  // 录音器采样率
        AVNumberOfChannelsKey: @1  // 音频通道数
    };
    [self initRecorder:recorderUrl withSettings:settings];
    
    // 添加中断通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    // 添加线路改变通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRouteChange:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
}

// 初始化音频播放
- (void)initPlay:(NSURL *)audioURL {
    if (audioURL) {
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:nil];
        if (self.audioPlayer) {
            NSLog(@"准备播放");
            // 使用prepareToPlay会取得需要的音频硬件并预加载Audio Queue的缓冲区
            // 调用prepareToPlay是可选的，当调用play方法时会隐性激活，不过创建时准备播放器可以降低调用play方法和听到声音输出之间的延时
            [self.audioPlayer prepareToPlay];
            // 设置循环播放
            [self.audioPlayer setNumberOfLoops:-1];
            // 设置允许设置速率
            self.audioPlayer.enableRate = YES;
            // 设置初始音量
            self.audioPlayer.volume = 0.5;
        }
    }
}

- (void)handleInterruption:(NSNotification *)notification {
    NSDictionary *interruptInfo = notification.userInfo;
    // 获取中断类型
    AVAudioSessionInterruptionType type = [interruptInfo[AVAudioSessionInterruptionTypeKey] unsignedIntValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        // 系统中断了audio session
        [self pauseClick];  // 发生中断，暂停播放
    } else if (type == AVAudioSessionInterruptionTypeEnded) {
        // 中断完成
        AVAudioSessionInterruptionOptions options = [interruptInfo[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
        // 若音频会话重新激活则再次播放
        if (options == AVAudioSessionInterruptionOptionShouldResume) {
            // 重新播放
            [self playClick];
        }
    }
}

- (void)handleRouteChange:(NSNotification *)notification {
    NSDictionary *routeChangeInfo = notification.userInfo;
    AVAudioSessionRouteChangeReason reason = [routeChangeInfo[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
    // 一个旧设备不可用，如耳机拔出
    if (reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        // 取出所有线路描述
        AVAudioSessionRouteDescription *previousRoute = routeChangeInfo[AVAudioSessionRouteChangePreviousRouteKey];
        // 取出前一次线路描述
        AVAudioSessionPortDescription *previousOutput = previousRoute.outputs[0];
        NSString *portType = previousOutput.portType;
        if ([portType isEqualToString:AVAudioSessionPortHeadphones]) {
            [self stopClick];
        }
        
    }
}

// 创建播放相关按钮
- (void)createPlayBth {
    // 播放
    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    playBtn.frame= CGRectMake(50, 100, 100, 40);
    [playBtn setTitle:@"播放" forState:UIControlStateNormal];
    [playBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    playBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:playBtn];
    [playBtn addTarget:self action:@selector(playClick) forControlEvents:UIControlEventTouchUpInside];
    
    // 暂停
    UIButton *pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    pauseBtn.frame= CGRectMake(50, 150, 100, 40);
    [pauseBtn setTitle:@"暂停" forState:UIControlStateNormal];
    [pauseBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    pauseBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:pauseBtn];
    [pauseBtn addTarget:self action:@selector(pauseClick) forControlEvents:UIControlEventTouchUpInside];
    
    // 停止
    UIButton *stopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    stopBtn.frame= CGRectMake(50, 200, 100, 40);
    [stopBtn setTitle:@"停止" forState:UIControlStateNormal];
    [stopBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    stopBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:stopBtn];
    [stopBtn addTarget:self action:@selector(stopClick) forControlEvents:UIControlEventTouchUpInside];
    
    UISegmentedControl *rateSegment = [[UISegmentedControl alloc] initWithItems:@[@"x0.5", @"x1.0", @"x1.5", @"x2.0"]];
    rateSegment.frame = CGRectMake(10, 300, 300, 30);
    rateSegment.selectedSegmentIndex = 1;
    [rateSegment addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:rateSegment];
    
    UISlider *volumnSlider = [[UISlider alloc] initWithFrame:CGRectMake(10, 350, 300, 30)];
    [self.view addSubview:volumnSlider];
    volumnSlider.minimumValue = 0.0;
    volumnSlider.maximumValue = 1.0;
    volumnSlider.value = 0.5;
    [volumnSlider addTarget:self action:@selector(volumnChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)valueChanged:(UISegmentedControl *)segment {
    // 读取控件
    [self adjustRate:(segment.selectedSegmentIndex + 1) * 0.5];
}

- (void)volumnChanged:(UISlider *)slider {
    [self adjustVolumn:slider.value];
}

// 播放音频
- (void)playClick {
    if (self.audioPlayer && ![self.audioPlayer isPlaying]) {
        NSLog(@"开始播放");
        [self.audioPlayer play];
    }
}

// 暂停播放音频
- (void)pauseClick {
    if (self.audioPlayer && [self.audioPlayer isPlaying]) {
        NSLog(@"暂停播放");
        // 调用stop不会撤销调用prepareToPlay时所做的设置
        [self.audioPlayer pause];
    }
}

// 停止播放音频
- (void)stopClick {
    if (self.audioPlayer) {
        NSLog(@"停止播放");
        // 调用stop会撤销调用prepareToPlay时所做的设置
        [self.audioPlayer stop];
        // 如果停止我希望下次播放从头开始
        self.audioPlayer.currentTime = 0;
    }
}

// 调整播放率，允许用户在不改变音调的情况下调整播放率，从0.5（半速）到2.0（2倍速）
- (void)adjustRate:(float)rate {
    self.audioPlayer.rate = rate;
}

// 调整pan值，允许使用立体声播放声音，从-1.0(极左)到-2.0(极右)，默认值为0.0(居中)
//- (void)adjustPan:(float)pan {
//
//}

// 设置播放器音量，独立于系统音量，从0.0(静音)到1.0(最大音量)之间的浮点值
- (void)adjustVolumn:(float)volumn {
    self.audioPlayer.volume = volumn;
}

- (void)initRecorder:(NSURL *)recorderUrl withSettings:(NSDictionary *)settings {
    if (recorderUrl) {
        NSError *error;
        self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:recorderUrl settings:settings error:&error];
        if (self.audioRecorder) {
            [self.audioRecorder prepareToRecord];
        } else {
            NSLog(@"init error: %@", [error localizedDescription]);
        }
    }
}

- (void)createRecordBtn {
    UIButton *recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    recordBtn.frame= CGRectMake(200, 100, 100, 40);
    [recordBtn setTitle:@"录制" forState:UIControlStateNormal];
    [recordBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    recordBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:recordBtn];
    [recordBtn addTarget:self action:@selector(recordClick) forControlEvents:UIControlEventTouchUpInside];
    
    // 暂停
    UIButton *pauseRecordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    pauseRecordBtn.frame= CGRectMake(200, 150, 100, 40);
    [pauseRecordBtn setTitle:@"暂停" forState:UIControlStateNormal];
    [pauseRecordBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    pauseRecordBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:pauseRecordBtn];
    [pauseRecordBtn addTarget:self action:@selector(pauseRecordClick) forControlEvents:UIControlEventTouchUpInside];
    
    // 停止
    UIButton *stopRecordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    stopRecordBtn.frame= CGRectMake(200, 200, 100, 40);
    [stopRecordBtn setTitle:@"停止" forState:UIControlStateNormal];
    [stopRecordBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    stopRecordBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:stopRecordBtn];
    [stopRecordBtn addTarget:self action:@selector(stopRecordClick) forControlEvents:UIControlEventTouchUpInside];
    
    // 播放录音
    UIButton *playRecordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    playRecordBtn.frame= CGRectMake(200, 250, 100, 40);
    [playRecordBtn setTitle:@"播放录音" forState:UIControlStateNormal];
    [playRecordBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    playRecordBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:playRecordBtn];
    [playRecordBtn addTarget:self action:@selector(playRecord) forControlEvents:UIControlEventTouchUpInside];
}

- (void)recordClick {
    if (self.audioRecorder && !self.audioRecorder.isRecording) {
        [self.audioRecorder record];
    }
}

- (void)pauseRecordClick {
    if (self.audioRecorder && self.audioRecorder.isRecording) {
        NSLog(@"-->%f", self.audioRecorder.currentTime);
        [self.audioRecorder pause];
    }
}

- (void)stopRecordClick {
    if (self.audioRecorder) {
        [self.audioRecorder stop];
    }
}

- (void)playRecord {
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"1.caf"];
    NSURL *recorderUrl = [NSURL fileURLWithPath:path];
    if (recorderUrl) {
        if (self.audioPlayer) {
            self.audioPlayer = nil;
        }
        [self initPlay:recorderUrl];
        [self playClick];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
}

@end
