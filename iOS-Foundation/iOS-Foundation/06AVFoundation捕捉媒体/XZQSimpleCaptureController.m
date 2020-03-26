//
//  XZQSimpleCaptureController.m
//  iOS-Foundation
//
//  Created by qhzc-iMac-02 on 2020/3/26.
//  Copyright © 2020 Xuzq. All rights reserved.
//

#import "XZQSimpleCaptureController.h"

@interface XZQSimpleCaptureController ()

@end

@implementation XZQSimpleCaptureController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self simpleCapture];
    
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

- (void)simpleCapture {
    // 创建捕捉会话AVCaptureSession
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    // 创建捕捉设备AVCaptureDevice
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 创建捕捉输入
    NSError *error;
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    // 将捕捉输入加入捕捉设备
    if ([session canAddInput:input]) {
        [session addInput:input];
    }
    // 创建捕捉输出，这里是静态图片输出
    AVCapturePhotoOutput *output = [[AVCapturePhotoOutput alloc] init];
    // 将捕捉输出加入捕捉设备
    if ([session canAddOutput:output]) {
        [session addOutput:output];
    }
    // 创建预览图层
    AVCaptureVideoPreviewLayer *layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    layer.frame = self.view.frame;
    [self.view.layer addSublayer:layer];
    // 开始捕捉
    [session startRunning];
}

@end
