//
//  DYYDownLoaderManager.h
//  DYYDownLoader
//
//  Created by yang on 2017/7/12.
//  Copyright © 2017年 dingyangyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DYYDownLoader.h"
@interface DYYDownLoaderManager : NSObject
+ (instancetype)shareManager;

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
 暂停下载
 */
- (void)pauseWithUrl:(NSURL *)url;

/**
 继续下载
 */
- (void)resumeWithURL:(NSURL *)url;


/**
 取消下载
 */
- (void)cancelWithUrl:(NSURL *)url;

/**
 取消下载并且清除下载文件
 */
- (void)cancelAndCleanWithUrl:(NSURL *)url;
/**
 暂停全部
 */
- (void)pauseAll;

/**
 继续下载全部
 */
- (void)resumeAll;

/**
 取消全部
 */
- (void)cancelAll;

/**
 取消全部下载并且清除全部下载文件
 */
- (void)cancelAndCleanAll;

@end
