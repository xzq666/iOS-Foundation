//
//  XZQScanController.m
//  iOS-Foundation
//
//  Created by qhzc-iMac-02 on 2020/3/31.
//  Copyright © 2020 Xuzq. All rights reserved.
//

#import "XZQScanController.h"

@interface XZQScanController ()<AVCaptureMetadataOutputObjectsDelegate>

// 捕捉会话
@property(nonatomic,strong) AVCaptureSession *session;
// 当前会话输入
@property(nonatomic,strong) AVCaptureDeviceInput *activeVideoInput;
// 会话输出
@property(nonatomic,strong) AVCaptureMetadataOutput *metadataOutput;

@end

@implementation XZQScanController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
    close.frame= CGRectMake(20, 40, 100, 40);
    [close setTitle:@"关闭" forState:UIControlStateNormal];
    [close setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    close.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:close];
    [close addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    startBtn.frame= CGRectMake(140, 40, 100, 40);
    [startBtn setTitle:@"开始扫码" forState:UIControlStateNormal];
    [startBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    startBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:startBtn];
    [startBtn addTarget:self action:@selector(startSession) forControlEvents:UIControlEventTouchUpInside];
    
    // 1.创建会话
    [self createSession];
    // 2.设置会话输入
    [self setInputSession];
    // 3.设置会话输出
    [self setOutputSession];
    // 4.创建预览图层
    AVCaptureVideoPreviewLayer *layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    layer.frame = self.view.frame;
    [self.view.layer addSublayer:layer];
}

- (void)startSession {
    if (![self.session isRunning]) {
        [self.session startRunning];
    }
}

// 创建会话
- (void)createSession {
    self.session = [[AVCaptureSession alloc] init];
    // 设置会话预设类型，建议使用最低合理解决方案以提高性能
    self.session.sessionPreset = AVCaptureSessionPreset640x480;
}

// 设置会话输入
- (void)setInputSession {
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (videoInput) {
        // 添加会话输入
        if ([self.session canAddInput:videoInput]) {
            [self.session addInput:videoInput];
            self.activeVideoInput = videoInput;
        }
        // 设置自动对焦
        if (self.activeVideoInput.device.autoFocusRangeRestrictionSupported) {  // 判断是否支持自动对焦
            if ([self.activeVideoInput.device lockForConfiguration:&error]) {
                // 捕捉设备的自动对焦通常在任何距离都可以进行扫描
                // 不过大部分条码距离都不远，所以可以缩小扫描区域来提升识别成功率
                [self.activeVideoInput.device unlockForConfiguration];
            }
        }
    }
}

// 设置会话输出
- (void)setOutputSession {
    self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    if ([self.session canAddOutput:self.metadataOutput]) {
        [self.session addOutput:self.metadataOutput];
        // 设置代理
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        [self.metadataOutput setMetadataObjectsDelegate:self queue:mainQueue];
        // 设置元数据类型，这里设置对象是QR码和Aztec码（一种二维码的制式，主要用于航空）
        NSArray *types = @[AVMetadataObjectTypeQRCode,
                           AVMetadataObjectTypeAztecCode,];
        self.metadataOutput.metadataObjectTypes = types;
    }
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    // 处理元数据
    for (AVMetadataMachineReadableCodeObject *code in metadataObjects) {
        NSString *stringValue = code.stringValue;
        // 这个就是条形码的值
        // 不过一般一次只有一个值，或者直接取第一个元素即为条码值
        NSLog(@"result-->%@", stringValue);
    }
    // 处理结束
    if ([self.session isRunning]) {
        [self.session stopRunning];
    }
}

- (void)closeClick {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
