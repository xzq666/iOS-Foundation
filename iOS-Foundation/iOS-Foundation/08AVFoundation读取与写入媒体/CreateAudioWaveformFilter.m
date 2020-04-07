//
//  CreateAudioWaveformFilter.m
//  iOS-Foundation
//
//  Created by qhzc-iMac-02 on 2020/4/7.
//  Copyright © 2020 Xuzq. All rights reserved.
//

#import "CreateAudioWaveformFilter.h"

@interface CreateAudioWaveformFilter ()

@property(nonatomic,strong) NSData *sampleData;

@end

@implementation CreateAudioWaveformFilter

- (id)initWithData:(NSData *)sampleData {
    if (self = [super init]) {
        self.sampleData = sampleData;
    }
    return self;
}

// 指定尺寸约束筛选数据集
- (NSArray *)filterSamplesForSize:(CGSize)size {
    NSMutableArray *filterDataSamples = [[NSMutableArray alloc] init];
    
    // 样本总长度
    NSUInteger sampleCount = self.sampleData.length / sizeof(SInt16);
    // 子样本长度
    NSUInteger binSize = sampleCount / size.width;
    
    SInt16 *bytes = (SInt16 *)self.sampleData.bytes;
    SInt16 maxSample = 0;
    
    // 迭代所有样本集合
    for (NSUInteger i = 0; i < sampleCount; i += binSize) {
        SInt16 sampleBin[binSize];
        for (NSUInteger j = 0; j < binSize; j++) {
            // CFSwapInt16LittleToHost确保样本是按主机内置的字节顺序处理
            sampleBin[j] = CFSwapInt16LittleToHost(bytes[i + j]);
        }
        SInt16 value = [self maxValueInArray:sampleBin ofSize:binSize];
        
        // 找到样本最大绝对值
        [filterDataSamples addObject:@(value)];
        
        if (value > maxSample) {
            maxSample = value;
        }
    }
    
    // 所有样本中的最大值，计算筛选样本使用的比例因子
    CGFloat scaleFactor = (size.height / 2) / maxSample;
    
    for (NSUInteger i = 0; i < filterDataSamples.count; i++) {
        filterDataSamples[i] = @([filterDataSamples[i] integerValue] * scaleFactor);
    }
    
    return filterDataSamples;
}

- (SInt16)maxValueInArray:(SInt16[])values ofSize:(NSUInteger)size {
    SInt16 maxValue = 0;
    for (int i = 0; i < size; i++) {
        if (abs(values[i]) > maxValue) {
            maxValue = abs(values[i]);
        }
    }
    return maxValue;
}

@end
