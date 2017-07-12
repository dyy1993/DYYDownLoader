//
//  DYYDownLoader.h
//  DYYDownLoader
//
//  Created by yang on 2017/7/12.
//  Copyright © 2017年 dingyangyang. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, DYYDownLoadState){
    DYYDownLoadStatePause,
    DYYDownLoadStateDownLoading,
    DYYDownLoadStateSuccess,
    DYYDownLoadStateFailed
};
typedef void(^DownLoadInfoBlockType)(long long totalSize);
typedef void(^ProgressBlockType)(float progress);
typedef void(^SuccessBlockType)(NSString *filePath);
typedef void(^FailedBlockType)();
typedef void(^StateBlockType)(DYYDownLoadState state);

@interface DYYDownLoader : NSObject


/**
 下载/继续下载
 
 @param url 资源地址
 @param downLoadInfo 下载信息
 @param progress 下载进度
 @param successBlock 成功
 @param failedBlock 失败
 */
- (void)downloader:(NSURL *)url downLoadInfo:(DownLoadInfoBlockType)downLoadInfo progress:(ProgressBlockType)progress success:(SuccessBlockType)successBlock failed:(FailedBlockType)failedBlock;
/**
 下载资源/继续下载
 
 @param url 资源地址
 */
- (void)downloader:(NSURL *)url;

/**
 暂停下载
 */
- (void)pause;

/**
 继续下载
 */
-(void)resume;

/**
 取消下载
 */
- (void)cancel;

/**
 取消下载并且清除下载文件
 */
- (void)cancelAndClean;

@property(nonatomic, assign, readonly)DYYDownLoadState state;
@property(nonatomic, assign, readonly)float progress;


@property(nonatomic, copy)DownLoadInfoBlockType downLoadInfo;
@property(nonatomic, copy)SuccessBlockType successBlock;
@property(nonatomic, copy)FailedBlockType failedBlock;
@property(nonatomic, copy)ProgressBlockType progressChange;
@property(nonatomic, copy)StateBlockType stateChange;


@end
