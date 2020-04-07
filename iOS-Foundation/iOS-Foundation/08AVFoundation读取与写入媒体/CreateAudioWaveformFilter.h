//
//  CreateAudioWaveformFilter.h
//  iOS-Foundation
//
//  Created by qhzc-iMac-02 on 2020/4/7.
//  Copyright © 2020 Xuzq. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CreateAudioWaveformFilter : NSObject

- (id)initWithData:(NSData *)sampleData;

/*
 通过外部传入视图size决定内部数据过滤，这里为水平方向上每一个点分配一个数据块，所有样本中最大的点表示垂直方向上的高度
 */
- (NSArray *)filterSamplesForSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
