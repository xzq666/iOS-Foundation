//
//  XZQPhotoVideoCaptureController.m
//  iOS-Foundation
//
//  Created by qhzc-iMac-02 on 2020/3/26.
//  Copyright © 2020 Xuzq. All rights reserved.
//

#import "XZQPhotoVideoCaptureController.h"

@interface XZQPhotoVideoCaptureController ()<XZQVideoCaptureDelegate, AVCapturePhotoCaptureDelegate>

// 捕捉会话
@property(nonatomic,strong) AVCaptureSession *session;
// 当前摄像头输入
@property(nonatomic,strong) AVCaptureDeviceInput *activeVideoInput;
// 当前静态图片输出
@property(nonatomic,strong) AVCapturePhotoOutput *photoOutput;
@property(nonatomic,strong) AVCapturePhotoSettings *outputSettings;
// 当前视频文件输出
@property(nonatomic,strong) AVCaptureMovieFileOutput *movieFileOutput;

// 可用视频捕捉设备数量
@property(nonatomic,assign) NSUInteger camreaCount;

@end

@implementation XZQPhotoVideoCaptureController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createSession];
    
    UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
    close.frame= CGRectMake(20, 40, 100, 40);
    [close setTitle:@"关闭" forState:UIControlStateNormal];
    [close setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    close.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:close];
    [close addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *switchCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    switchCameraBtn.frame= CGRectMake(140, 40, 100, 40);
    [switchCameraBtn setTitle:@"切换摄像头" forState:UIControlStateNormal];
    [switchCameraBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    switchCameraBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:switchCameraBtn];
    [switchCameraBtn addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    startBtn.frame= CGRectMake(20, 100, 100, 40);
    [startBtn setTitle:@"开始录制" forState:UIControlStateNormal];
    [startBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    startBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:startBtn];
    [startBtn addTarget:self action:@selector(startSession) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *stopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    stopBtn.frame= CGRectMake(140, 100, 100, 40);
    [stopBtn setTitle:@"停止录制" forState:UIControlStateNormal];
    [stopBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    stopBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:stopBtn];
    [stopBtn addTarget:self action:@selector(stopSession) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *capturePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    capturePhotoBtn.frame= CGRectMake(20, 160, 100, 40);
    [capturePhotoBtn setTitle:@"拍摄图片" forState:UIControlStateNormal];
    [capturePhotoBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    capturePhotoBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:capturePhotoBtn];
    [capturePhotoBtn addTarget:self action:@selector(capturePhoto) forControlEvents:UIControlEventTouchUpInside];
}

// 创建捕捉会话并完成输入输出添加
- (void)createSession {
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    NSError *error;
    // 创建视频输入
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    // 添加视频输入
    if (videoInput && [self.session canAddInput:videoInput]) {
        NSLog(@"添加视频输入成功");
        [self.session addInput:videoInput];
        self.activeVideoInput = videoInput;
    }
    // 创建音频输入
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    // 添加音频输入
    if (audioDevice && [self.session canAddInput:audioInput]) {
        NSLog(@"添加音频输入成功");
        [self.session addInput:audioInput];
    }
    // 创建静态图片输出
    self.photoOutput = [[AVCapturePhotoOutput alloc] init];
    // 添加静态图片输出
    if (self.photoOutput && [self.session canAddOutput:self.photoOutput]) {
        NSLog(@"添加静态图片输出成功");
        [self.session addOutput:self.photoOutput];
    }
    // 创建视频文件输出
    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    NSDictionary *setDic = @{AVVideoCodecKey:AVVideoCodecTypeJPEG};
    self.outputSettings = [AVCapturePhotoSettings photoSettingsWithFormat:setDic];
    // 添加视频文件输出
    if (self.movieFileOutput && [self.session canAddOutput:self.movieFileOutput]) {
        NSLog(@"添加视频文件输出成功");
        [self.session addOutput:self.movieFileOutput];
    }
    // 添加捕捉预览层
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    layer.frame = self.view.frame;
    [self.view.layer addSublayer:layer];
}

// 切换摄像头
- (BOOL)switchCamera {
    if (![self canSwitchCamera]) {
        return NO;
    }
    NSError *error;
    // 当前未激活的摄像头
    AVCaptureDevice *videoDevice = [self inactiveCamera];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (videoInput) {
        // 标注配置变化即将开始
        [self.session beginConfiguration];
        
        // 改变配置
        // 移除当前输入摄像头
        [self.session removeInput:self.activeVideoInput];
        if ([self.session canAddInput:videoInput]) {
            [self.session addInput:videoInput];
            self.activeVideoInput = videoInput;
        } else if (self.activeVideoInput) {  // 若不能添加新的摄像头，则将原来的摄像头添加回去
            [self.session addInput:self.activeVideoInput];
        }
        
        // 标注配置变化结束并提交相应的变化
        [self.session commitConfiguration];
    } else {
        [self.delegate deviceConfigurationFailedWithError:error];
        return NO;
    }
    return YES;
}

// 返回当前未激活的摄像头
- (AVCaptureDevice *)inactiveCamera {
    AVCaptureDevice *device = nil;
    if (self.camreaCount > 1) {
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}

// 返回指定位置的AVCaptureDevice，遍历可用视频设备，并返回position参数对应的值
// 只看AVCaptureDevicePositionFront(前置摄像头)和AVCaptureDevicePositionBack(后置摄像头)
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [[AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified] devices];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

// 当前捕捉会话对应的摄像头，返回激活的捕捉设备输入的device属性
- (AVCaptureDevice *)activeCamera {
    return self.activeVideoInput.device;
}

// 判断是否可以切换摄像头
- (BOOL)canSwitchCamera {
    return self.camreaCount > 1;
}

// 可用视频捕捉设备的数量
- (NSUInteger)camreaCount {
    return [[AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified] devices].count;
}

// 开始捕捉会话
- (void)startSession {
    if (![self.session isRunning]) {
        dispatch_async([self globalQueue], ^{
            // 异步调用避免阻塞主线程
            [self.session startRunning];
        });
    }
}

// 停止捕捉会话
- (void)stopSession {
    if ([self.session isRunning]) {
        dispatch_async([self globalQueue], ^{
            // 异步调用避免阻塞主线程
            [self.session stopRunning];
        });
    }
}

- (dispatch_queue_t)globalQueue {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

// 捕捉静态图片
- (void)capturePhoto {
    NSLog(@"捕捉静态图片");
    // 处理图片方向问题
    AVCaptureConnection *connection = [self.photoOutput connectionWithMediaType:AVMediaTypeVideo];
    if (connection.isVideoOrientationSupported) {
        connection.videoOrientation = [self currentVideoOrientation];
    }
    [self.photoOutput capturePhotoWithSettings:self.outputSettings delegate:self];
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error {
    NSData *data = [photo fileDataRepresentation];
    UIImage *image = [UIImage imageWithData:data];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *msg = nil;
    if(error != NULL){
        msg = @"保存图片失败";
    }else{
        msg = @"保存图片成功";
    }
    NSLog(@"msg:%@", msg);
}

// 处理图片方向问题
- (AVCaptureVideoOrientation)currentVideoOrientation {
    AVCaptureVideoOrientation orientation;
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
            
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }
    return orientation;
}

- (void)closeClick {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)deviceConfigurationFailedWithError:(NSError *)error {
    NSLog(@"deviceConfigurationFailed: %@", error);
}

@end
