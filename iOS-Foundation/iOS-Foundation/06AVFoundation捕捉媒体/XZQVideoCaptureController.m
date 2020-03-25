//
//  XZQVideoCaptureController.m
//  iOS-Foundation
//
//  Created by qhzc-iMac-02 on 2020/3/25.
//  Copyright © 2020 Xuzq. All rights reserved.
//

#import "XZQVideoCaptureController.h"

@interface XZQVideoCaptureController ()

@property(nonatomic,strong) AVCaptureSession *captureSession;

@end

@implementation XZQVideoCaptureController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 创建捕捉会话AVCaptureSession
    self.captureSession = [[AVCaptureSession alloc] init];
    // 创建捕捉设备AVCaptureDevice
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 创建捕捉输入
    NSError *error;
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    // 将捕捉输入添加到会话中
    if ([self.captureSession canAddInput:input]) {
        [self.captureSession addInput:input];
    }
    // 创建捕捉输出
    AVCapturePhotoOutput *output = [[AVCapturePhotoOutput alloc] init];
    // 将捕捉输出添加到会话中
    if ([self.captureSession canAddOutput:output]) {
        [self.captureSession addOutput:output];
    }
    // 创建图像预览层
    AVCaptureVideoPreviewLayer *layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    layer.frame = self.view.frame;
    [self.view.layer addSublayer:layer];
    // 开始会话
    [self.captureSession startRunning];
    
    UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
    close.frame= CGRectMake(20, 40, 100, 40);
    [close setTitle:@"关闭" forState:UIControlStateNormal];
    [close setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    close.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:close];
    [close addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)closeClick {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
