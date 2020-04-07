//
//  CreateAudioWaveformUtil.m
//  iOS-Foundation
//
//  Created by qhzc-iMac-02 on 2020/4/7.
//  Copyright © 2020 Xuzq. All rights reserved.
//

#import "CreateAudioWaveformUtil.h"

@implementation CreateAudioWaveformUtil

/*
 加载AVAsset资源轨道数据
 */
+ (void)loadAudioSamplesFromAsset:(AVAsset *)asset completionBlock:(XZQSampleDataCompletionBlock)completionBlock {
    NSString *tracks = @"tracks";
    [asset loadValuesAsynchronouslyForKeys:@[tracks] completionHandler:^{
        AVKeyValueStatus status = [asset statusOfValueForKey:tracks error:nil];
        NSData *sampleData = nil;
        // 资源已加载完成
        if (status == AVKeyValueStatusLoaded) {
            sampleData = [self readAudioSamplesFromAsset:asset];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(sampleData);
        });
    }];
}

/*
 AVAssertReader读取数据，并将读取到的样本数据添加到NSData实例后面
 */
+ (NSData *)readAudioSamplesFromAsset:(AVAsset *)asset {
    NSError *error = nil;
    // 创建一个AVAssetReader实例，并赋给它一个资源读取
    AVAssetReader *assetReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    
    if (!assetReader) {
        NSLog(@"创建AVAssetReader出错：%@", error);
        return nil;
    }
    
    // 获取资源找到的第一个音频轨道，根据期望的媒体类型获取轨道
    AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    
    // 创建NSDictionary保存从资源轨道读取音频样本时使用的解压设置
    NSDictionary *outputSettings = @{
        AVFormatIDKey: @(kAudioFormatLinearPCM),  // 样本需要以未压缩的格式被读取
        AVLinearPCMIsBigEndianKey: @NO,
        AVLinearPCMIsFloatKey: @NO,
        AVLinearPCMBitDepthKey: @(16)};
        
    // 创建新的AVAssetReaderTrackOutput实例，将创建的输出设置传递给它
    // 将其作为AVAssetReader的输出并调用startReading来允许资源读取器开始预收取样本数据
    AVAssetReaderTrackOutput *trackOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:track outputSettings:outputSettings];
    if ([assetReader canAddOutput:trackOutput]) {
        [assetReader addOutput:trackOutput];
    }
    [assetReader startReading];

    NSMutableData *sampleData = [NSMutableData data];
    while (assetReader.status == AVAssetReaderStatusReading) {
        // 调用跟踪输出的方法开始迭代，每次返回一个包含音频样本的下一个可用样本buffer
        CMSampleBufferRef sampleBuffer = [trackOutput copyNextSampleBuffer];
        if (sampleBuffer) {
            // CMSampleBuffer中的音频样本包含在一个CMBlockBuffer类型中
            // CMSampleBufferGetDataBuffer函数可以返回block buffer
            CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBuffer);
            
            // 确定长度并创建一个16位带符号整型数组来保存音频样本
            size_t length = CMBlockBufferGetDataLength(blockBufferRef);
            SInt16 sampleBytes[length];
            
            // 生成一个数组，数组中元素为CMBlockBuffer所包含的数据
            CMBlockBufferCopyDataBytes(blockBufferRef, 0, length, sampleBytes);
            
            // 将数组数据内容附加在NDSData实例后面
            [sampleData appendBytes:sampleBytes length:length];
            
            // 指定样本buffer已经处理和不可再继续使用
            CMSampleBufferInvalidate(sampleBuffer);
            
            // 释放
            CFRelease(sampleBuffer);
        }
    }
    
    if (assetReader.status == AVAssetReaderStatusCompleted) {
        // 数据读取成功，返回包含音频样本数据的NSData
        return sampleData;
    } else {
        NSLog(@"读取音频样本失败");
        return nil;
    }
    
    return nil;
}

@end
