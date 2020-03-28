//
//  XZQPhotoVideoCaptureController.m
//  iOS-Foundation
//
//  Created by qhzc-iMac-02 on 2020/3/26.
//  Copyright © 2020 Xuzq. All rights reserved.
//

#import "XZQPhotoVideoCaptureController.h"
#import <Photos/Photos.h>

@interface XZQPhotoVideoCaptureController ()<XZQVideoCaptureDelegate, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate>

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

// 视频录制存储路径
@property(nonatomic,strong) NSURL *outputUrl;

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
    
    UIButton *startCaptureVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    startCaptureVideoBtn.frame= CGRectMake(20, 220, 100, 40);
    [startCaptureVideoBtn setTitle:@"开始录制视频" forState:UIControlStateNormal];
    [startCaptureVideoBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    startCaptureVideoBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:startCaptureVideoBtn];
    [startCaptureVideoBtn addTarget:self action:@selector(startCaptureVideo) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *stopCaptureVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    stopCaptureVideoBtn.frame= CGRectMake(140, 220, 100, 40);
    [stopCaptureVideoBtn setTitle:@"停止录制视频" forState:UIControlStateNormal];
    [stopCaptureVideoBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    stopCaptureVideoBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:stopCaptureVideoBtn];
    [stopCaptureVideoBtn addTarget:self action:@selector(stopCaptureVideo) forControlEvents:UIControlEventTouchUpInside];
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
    NSDictionary *setDic = @{AVVideoCodecKey:AVVideoCodecTypeJPEG};
    self.outputSettings = [AVCapturePhotoSettings photoSettingsWithFormat:setDic];
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

// 开始录制视频
- (void)startCaptureVideo {
    if (![self.movieFileOutput isRecording]) {
        NSLog(@"开始录制视频");
        AVCaptureConnection *videoConnection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([videoConnection isVideoOrientationSupported]) {
            videoConnection.videoOrientation = [self currentVideoOrientation];
        }
        // 标识视频录入时稳定音频流的接受，这里设置为自动
        // 支持视频稳定可以显著提升捕捉到的视频质量
        if ([videoConnection isVideoStabilizationSupported]) {
            videoConnection.preferredVideoStabilizationMode = YES;
        }
        AVCaptureDevice *device = [self activeCamera];
        if (device.isSmoothAutoFocusEnabled) {
            // 摄像头可以进行平滑对焦模式的操作，减慢摄像头镜头对焦的速度
            // 通常情况下，用户移动拍摄时摄像头会尝试快速自动对焦，这会在捕捉视频中出现脉冲式效果
            // 当平滑对焦时，会降低对焦操作的速率，从而提供更加自然的视频录制效果
            // 改变聚焦模式
            NSError *error;
            if ([device lockForConfiguration:&error]) {
                device.smoothAutoFocusEnabled = YES;
                [device unlockForConfiguration];
            } else {
                [self.delegate deviceConfigurationFailedWithError:error];
            }
        }
        self.outputUrl = [self videoSaveURL];
        [self.movieFileOutput startRecordingToOutputFileURL:self.outputUrl recordingDelegate:self];
    }
}

// 在代理回调中拿到录制视频的地址
- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error {
    if (error) {
        [self.delegate mediaCaptureFailedWithError:error];
    } else {
        NSLog(@"videoUrl-->%@", outputFileURL);
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:outputFileURL];
            NSLog(@"保存视频成功");
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            [self.delegate assetLibraryWriteFailedWithError:error];
        }];
    }
    self.outputUrl = nil;
}

- (void)mediaCaptureFailedWithError:(NSError *)error {
    NSLog(@"视频录制失败: %@", error);
}

- (void)assetLibraryWriteFailedWithError:(NSError *)error {
    NSLog(@"录制视频保存失败: %@", error);
}

// 停止录制视频
- (void)stopCaptureVideo {
    if ([self.movieFileOutput isRecording]) {
        NSLog(@"停止录制视频");
        [self.movieFileOutput stopRecording];
    }
}

// 设置录制视频存储路径
- (NSURL *)videoSaveURL {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 查找目录，返回指定范围内的指定名称的目录的路径集合
    NSString *directionPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"camera_movie"];
    NSLog(@"path: %@", directionPath);
    if (![fileManager fileExistsAtPath:directionPath]) {
        // 若不存在目录则创建目录
        [fileManager createDirectoryAtPath:directionPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    // 保存的视频文件路径
    NSString *filePath = [directionPath stringByAppendingPathComponent:@"camera_movie.mov"];
    if ([fileManager fileExistsAtPath:filePath]) {
        // 文件已存在先移除
        [fileManager removeItemAtPath:filePath error:nil];
    }
    return [NSURL fileURLWithPath:filePath];
}

- (void)closeClick {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)deviceConfigurationFailedWithError:(NSError *)error {
    NSLog(@"deviceConfigurationFailed: %@", error);
}

@end
