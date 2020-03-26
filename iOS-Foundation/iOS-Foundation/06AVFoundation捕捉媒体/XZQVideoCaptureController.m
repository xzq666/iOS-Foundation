//
//  XZQVideoCaptureController.m
//  iOS-Foundation
//
//  Created by qhzc-iMac-02 on 2020/3/25.
//  Copyright © 2020 Xuzq. All rights reserved.
//

#import "XZQVideoCaptureController.h"
#import "XZQSimpleCaptureController.h"
#import "XZQPhotoVideoCaptureController.h"

@interface XZQVideoCaptureController ()

@property(nonatomic,strong) AVCaptureSession *captureSession;

@end

@implementation XZQVideoCaptureController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createUI];
}

- (void)createUI {
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(20, 100, 100, 30);
    [btn1 setTitle:@"简单视频捕捉" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    btn1.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [self.view addSubview:btn1];
    [btn1 addTarget:self action:@selector(btn1Click) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(160, 100, 100, 30);
    [btn2 setTitle:@"简单拍照视频" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    btn2.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [self.view addSubview:btn2];
    [btn2 addTarget:self action:@selector(btn2Click) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btn1Click {
    XZQSimpleCaptureController *simpleCapture = [[XZQSimpleCaptureController alloc] init];
    simpleCapture.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:simpleCapture animated:YES completion:^{
        
    }];
}

- (void)btn2Click {
    XZQPhotoVideoCaptureController *photoVideoCapture = [[XZQPhotoVideoCaptureController alloc] init];
    photoVideoCapture.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:photoVideoCapture animated:YES completion:^{
        
    }];
}

@end
