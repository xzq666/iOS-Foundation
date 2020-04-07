//
//  XZQCreateAudioWaveformController.m
//  iOS-Foundation
//
//  Created by qhzc-iMac-02 on 2020/4/7.
//  Copyright © 2020 Xuzq. All rights reserved.
//

#import "XZQCreateAudioWaveformController.h"
#import "XZQWaveformView.h"

@interface XZQCreateAudioWaveformController ()

@end

@implementation XZQCreateAudioWaveformController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSURL *audioUrl = [[NSBundle mainBundle] URLForResource:@"把故事写成我们" withExtension:@"mp3"];
    AVAsset *asset = [AVAsset assetWithURL:audioUrl];
    
    XZQWaveformView *waveformView = [[XZQWaveformView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width / 4) asset:asset];
    [self.view addSubview:waveformView];
}

@end
