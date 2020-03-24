//
//  XZQAVkitController.m
//  iOS-Foundation
//
//  Created by qhzc-iMac-02 on 2020/3/24.
//  Copyright © 2020 Xuzq. All rights reserved.
//

#import "XZQAVkitController.h"
#import <AVKit/AVKit.h>

@interface XZQAVkitController ()

@end

@implementation XZQAVkitController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createUI];
}

- (void)createUI {
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(20, 100, 100, 30);
    [btn1 setTitle:@"简单创建" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    btn1.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [self.view addSubview:btn1];
    [btn1 addTarget:self action:@selector(btn1Click) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(160, 100, 100, 30);
    [btn2 setTitle:@"完整创建" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    btn2.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [self.view addSubview:btn2];
    [btn2 addTarget:self action:@selector(btn2Click) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btn1Click {
    AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
    playerVC.player = [AVPlayer playerWithURL:[[NSBundle mainBundle] URLForResource:@"test" withExtension:@"mp4"]];
    playerVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:playerVC animated:YES completion:^{
        
    }];
}

- (void)btn2Click {
    NSURL *videoUrl = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"mp4"];
    AVAsset *asset = [AVAsset assetWithURL:videoUrl];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
    playerVC.player = player;
    playerVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:playerVC animated:YES completion:^{
        
    }];
}

@end
