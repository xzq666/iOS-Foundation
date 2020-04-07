//
//  CreateAudioWaveformUtil.h
//  iOS-Foundation
//
//  Created by qhzc-iMac-02 on 2020/4/7.
//  Copyright © 2020 Xuzq. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^XZQSampleDataCompletionBlock)(NSData *);

@interface CreateAudioWaveformUtil : NSObject

/*
 加载AVAsset资源轨道数据
 */
+ (void)loadAudioSamplesFromAsset:(AVAsset *)asset completionBlock:(XZQSampleDataCompletionBlock)completionBlock;

/*
 AVAssertReader读取数据，并将读取到的样本数据添加到NSData实例后面
 */
+ (NSData *)readAudioSamplesFromAsset:(AVAsset *)asset;

@end

NS_ASSUME_NONNULL_END
