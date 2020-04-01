//
//  XZQReadAndWriteMediaController.m
//  iOS-Foundation
//
//  Created by qhzc-iMac-02 on 2020/4/1.
//  Copyright © 2020 Xuzq. All rights reserved.
//

#import "XZQReadAndWriteMediaController.h"

@interface XZQReadAndWriteMediaController ()

// AVAssetReader媒体读取
@property(nonatomic,strong) AVAssetReader *assetReader;
// 读取器
@property(nonatomic,strong) AVAssetReaderTrackOutput *trackOutput;
// AVAssetWriter媒体写入
@property(nonatomic,strong) AVAssetWriter *assetWriter;
// 写入器
@property(nonatomic,strong) AVAssetWriterInput *assetInput;

@property(nonatomic,strong) UIImageView *imageView;

@end

@implementation XZQReadAndWriteMediaController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 100, 80, 40);
    [btn setTitle:@"开始写入" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(write) forControlEvents:UIControlEventTouchUpInside];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 200, 200, 200)];
    self.imageView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.imageView];
}

- (void)test {
    NSURL *videoUrl = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"mp4"];
    AVAsset *asset = [AVAsset assetWithURL:videoUrl];
    NSError *error;
    //创建AVAssetReader对象用来读取asset数据
    self.assetReader = [AVAssetReader assetReaderWithAsset:asset error:&error];
    AVAsset *localAsset = self.assetReader.asset;
    AVAssetTrack *videoTrack = [[localAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    AVAssetTrack *audioTrack = [[localAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];

    NSDictionary *videoSetting = @{(id)kCVPixelBufferPixelFormatTypeKey     : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA],
                                   (id)kCVPixelBufferIOSurfacePropertiesKey : [NSDictionary dictionary],
                                   };
    //AVAssetReaderTrackOutput用来设置怎么读数据
    self.trackOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:videoSetting];
    //音频以pcm流的形似读数据
    NSDictionary *audioSetting = @{AVFormatIDKey : [NSNumber numberWithUnsignedInt:kAudioFormatLinearPCM]};
    AVAssetReaderTrackOutput *readerAudioTrackOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:audioTrack outputSettings:audioSetting];

    if ([self.assetReader canAddOutput:self.trackOutput]) {
        [self.assetReader addOutput:self.trackOutput];
    }

    if ([self.assetReader canAddOutput:readerAudioTrackOutput]) {
        [self.assetReader addOutput:readerAudioTrackOutput];
    }
    //开始读
    [self.assetReader startReading];

    
    NSString *path = nil;
    NSRange range = [videoUrl.absoluteString rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        NSString *pathRoot = [videoUrl.absoluteString substringToIndex:range.location];
        path = [pathRoot stringByAppendingPathComponent:@"copy.mp4"];
    }
    NSURL *writerUrl = [NSURL fileURLWithPath:path];
    //创建一个写数据对象
    self.assetWriter = [[AVAssetWriter alloc] initWithURL:writerUrl fileType:AVFileTypeMPEG4 error:nil];
    //配置写数据，设置比特率，帧率等
    NSDictionary *compressionProperties = @{ AVVideoAverageBitRateKey : @(1.38*1024*1024),
                                             AVVideoExpectedSourceFrameRateKey: @(30),
                                             AVVideoProfileLevelKey : AVVideoProfileLevelH264HighAutoLevel };
    //配置编码器宽高等
    NSDictionary *compressionVideoSetting = @{
                              AVVideoCodecKey                   : AVVideoCodecTypeH264,
                              AVVideoWidthKey                   : @1080,
                              AVVideoHeightKey                  : @1080,
                              AVVideoCompressionPropertiesKey   : compressionProperties
                              };

    AudioChannelLayout stereoChannelLayout = {
        .mChannelLayoutTag = kAudioChannelLayoutTag_Stereo,
        .mChannelBitmap = 0,
        .mNumberChannelDescriptions = 0
    };
    NSData *channelLayoutAsData = [NSData dataWithBytes:&stereoChannelLayout length:offsetof(AudioChannelLayout, mChannelDescriptions)];
    //写入音频配置
    NSDictionary *compressionAudioSetting = @{
                                               AVFormatIDKey         : [NSNumber numberWithUnsignedInt:kAudioFormatMPEG4AAC],
                                               AVEncoderBitRateKey   : [NSNumber numberWithInteger:64000],
                                               AVSampleRateKey       : [NSNumber numberWithInteger:44100],
                                               AVChannelLayoutKey    : channelLayoutAsData,
                                               AVNumberOfChannelsKey : [NSNumber numberWithUnsignedInteger:2]
                                               };
    //AVAssetWriterInput用来说明怎么写数据
    self.assetInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:compressionVideoSetting];
    AVAssetWriterInput *assetAudioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:compressionAudioSetting];

    if ([self.assetWriter canAddInput:self.assetInput]) {
        [self.assetWriter addInput:self.assetInput];
    }
    if ([self.assetWriter canAddInput:assetAudioWriterInput]) {
        [self.assetWriter addInput:assetAudioWriterInput];
    }
    //开始写
    [self.assetWriter startWriting];
    [self.assetWriter startSessionAtSourceTime:kCMTimeZero];
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t videoWriter = dispatch_queue_create("videoWriter", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t audioWriter = dispatch_queue_create("audioWriter", DISPATCH_QUEUE_CONCURRENT);
    __block BOOL isVideoComplete = NO;
    dispatch_group_enter(group);
    //要想写数据，就带有数据源，以下是将readerVideoTrackOutput读出来的数据加入到assetVideoWriterInput中再写入本地，音频和视频读取写入方式一样
    [self.assetInput requestMediaDataWhenReadyOnQueue:videoWriter usingBlock:^{
        while (!isVideoComplete && self.assetInput.isReadyForMoreMediaData) {
            //样本数据
            @autoreleasepool {
                //每次读取一个buffer
                CMSampleBufferRef buffer = [self.trackOutput copyNextSampleBuffer];
                if (buffer) {
                    //将读来的buffer加入到写对象中开始写
                    //此处也可以给assetVideoWriterInput加个适配器对象可以写入CVPixelBuffer
                    [self.assetInput appendSampleBuffer:buffer];
                    //将buffer生成图片
                    UIImage *image = [self imageFromSampleBuffer:buffer];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.imageView.image = image;
                    });
                    CFRelease(buffer);
                    buffer = NULL;
                } else {
                    isVideoComplete = YES;
                }
            }

        }
        if (isVideoComplete) {
            //关闭写入会话
            [self.assetInput markAsFinished];
            dispatch_group_leave(group);
        }
    }];
    __block BOOL isAudioComplete = NO;
    dispatch_group_enter(group);
    [assetAudioWriterInput requestMediaDataWhenReadyOnQueue:audioWriter usingBlock:^{
        while (!isAudioComplete && assetAudioWriterInput.isReadyForMoreMediaData) {
            //样本数据
            CMSampleBufferRef buffer = [readerAudioTrackOutput copyNextSampleBuffer];
            if (buffer) {
                [assetAudioWriterInput appendSampleBuffer:buffer];
                CFRelease(buffer);
                buffer = NULL;
            } else {
                isAudioComplete = YES;
            }

        }
        if (isAudioComplete) {
            //关闭写入会话
            [assetAudioWriterInput markAsFinished];
            dispatch_group_leave(group);
        }
    }];

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"OKKK");
        [self.assetWriter finishWritingWithCompletionHandler:^{
            AVAssetWriterStatus status = self.assetWriter.status;
            if (status == AVAssetWriterStatusCompleted) {
                NSLog(@"video finsished");
                [self.assetReader cancelReading];
                [self.assetWriter cancelWriting];
            } else {
                NSLog(@"video failure");
                NSLog(@"%@", self.assetWriter.error);
            }

        }];
    });
}

- (void)write {
    [self configureAssetReader];
    [self configureAssetWriter];
    [self assetReadToAssetInput];
}

// 配置读取
- (void)configureAssetReader {
    NSURL *videoUrl = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"mp4"];
    AVAsset *asset = [AVAsset assetWithURL:videoUrl];
    AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    // 读取
    NSError *error;
    self.assetReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    // 从资源视频轨道中读取样本，将视频帧解压缩为BGRA格式
    NSDictionary *readerOutputSetting = @{
        (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)
    };
    self.trackOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:track outputSettings:readerOutputSetting];
    if ([self.assetReader canAddOutput:self.trackOutput]) {
        [self.assetReader addOutput:self.trackOutput];
    }
    [self.assetReader startReading];
}

// 配置写入
- (void)configureAssetWriter {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *directionPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"copy_movie"];
    NSLog(@"path: %@", directionPath);
    if (![fileManager fileExistsAtPath:directionPath]) {
        // 若不存在目录则创建目录
        [fileManager createDirectoryAtPath:directionPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    // 保存的视频文件路径
    NSString *storePath = [directionPath stringByAppendingPathComponent:@"copy1.mp4"];
    if (storePath) {
        NSError *error;
        self.assetWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:storePath] fileType:AVFileTypeQuickTimeMovie error:&error];
        // 指定编码格式、像素宽高等信息
        NSDictionary *writerOutputSettings = @{
            AVVideoCodecKey:AVVideoCodecTypeH264,
            AVVideoWidthKey:@1280,
            AVVideoHeightKey:@720,
            AVVideoCompressionPropertiesKey:@{
                AVVideoMaxKeyFrameIntervalKey:@1,
                AVVideoAverageBitRateKey:@10500000,
                AVVideoProfileLevelKey:AVVideoProfileLevelH264Main31,
            }
        };
        self.assetInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:writerOutputSettings];
        // 添加写入器
        if ([self.assetWriter canAddInput:self.assetInput]) {
            [self.assetWriter addInput:self.assetInput];
        }
        [self.assetWriter startWriting];
    }
}

// 将读取的视频写入到写入器中
- (void)assetReadToAssetInput {
    dispatch_queue_t queue = dispatch_queue_create("com.writequeue", DISPATCH_QUEUE_CONCURRENT);
    if (self.assetInput) {
        __block BOOL isComplete = NO;
        // 开启写入会话，并指定样本的开始时间
        [self.assetWriter startSessionAtSourceTime:kCMTimeZero];
        [self.assetInput requestMediaDataWhenReadyOnQueue:queue usingBlock:^{
            while (!isComplete && self.assetInput.readyForMoreMediaData) {
                // 样本数据
                CMSampleBufferRef buffer = [self.trackOutput copyNextSampleBuffer];
                if (buffer) {
                    [self.assetInput appendSampleBuffer:buffer];
                    //将buffer生成图片
                    UIImage *image = [self imageFromSampleBuffer:buffer];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.imageView.image = image;
                    });
                    CFRelease(buffer);
                    buffer = NULL;
                } else {
                    [self.assetInput markAsFinished];
                    isComplete = YES;
                }
            }
            if (isComplete) {
                [self.assetWriter finishWritingWithCompletionHandler:^{
                    AVAssetWriterStatus status = self.assetWriter.status;
                    if (status == AVAssetWriterStatusCompleted) {
                        NSLog(@"写入完毕");
                        [self.assetReader cancelReading];
                        [self.assetWriter cancelWriting];
                    } else {
                        NSLog(@"写入出错: %@", self.assetWriter.error);
                    }
                }];
            }
        }];
    }
}

//转换图片
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    // 释放context和颜色空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    // 用Quartz image创建一个UIImage对象image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    // 释放Quartz image对象
    CGImageRelease(quartzImage);
    return image;
}

@end
