//
//  DYYDownLoaderManager.m
//  DYYDownLoader
//
//  Created by yang on 2017/7/12.
//  Copyright © 2017年 dingyangyang. All rights reserved.
//

#import "DYYDownLoaderManager.h"
#import "NSString+MD5.h"
@interface DYYDownLoaderManager()<NSCopying>
@property (nonatomic, strong)NSMutableDictionary *downLoaderM;
@end
@implementation DYYDownLoaderManager
static DYYDownLoaderManager *_downLoaderManager = nil;
+(instancetype)shareManager{
    if (!_downLoaderManager) {
        _downLoaderManager = [[self alloc] init];
    }
    return _downLoaderManager;
}
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _downLoaderManager = [super allocWithZone:zone];
    });
    return _downLoaderManager;
}
-(id)copyWithZone:(NSZone *)zone{
    
    return _downLoaderManager;
}
-(id)mutableCopy{
    
    return _downLoaderManager;
}
-(NSMutableDictionary *)downLoaderM{
    
    if (!_downLoaderM) {
        _downLoaderM = [NSMutableDictionary dictionary];
    }
    return _downLoaderM;
}


- (void)downloader:(NSURL *)url downLoadInfo:(DownLoadInfoBlockType)downLoadInfo progress:(ProgressBlockType)progress success:(SuccessBlockType)successBlock failed:(FailedBlockType)failedBlock{
    NSString *urlMD5 = url.absoluteString.md5String;
    DYYDownLoader *downLoader = self.downLoaderM[urlMD5];
    if (downLoader == nil) {
        downLoader = [[DYYDownLoader alloc] init];
        self.downLoaderM[urlMD5] = downLoader;
    }
    __weak typeof(self) weakSelf = self;
    [downLoader downloader:url downLoadInfo:downLoadInfo progress:progress success:^(NSString *filePath) {
        [weakSelf.downLoaderM removeObjectForKey:urlMD5];
        successBlock(filePath);
        
    } failed:failedBlock];
    
}
/**
 暂停下载
 */
- (void)pauseWithUrl:(NSURL *)url{
    NSString *urlMD5 = url.absoluteString.md5String;
    DYYDownLoader *downLoader = self.downLoaderM[urlMD5];
    [downLoader pause];
}

/**
 继续下载
 */
- (void)resumeWithURL:(NSURL *)url{
    NSString *urlMD5 = url.absoluteString.md5String;
    DYYDownLoader *downLoader = self.downLoaderM[urlMD5];
    [downLoader resume];
    
}
/**
 取消下载
 */
- (void)cancelWithUrl:(NSURL *)url{
    NSString *urlMD5 = url.absoluteString.md5String;
    DYYDownLoader *downLoader = self.downLoaderM[urlMD5];
    [downLoader cancel];
}

/**
 取消下载并且清除下载文件
 */
- (void)cancelAndCleanWithUrl:(NSURL *)url{
    NSString *urlMD5 = url.absoluteString.md5String;
    DYYDownLoader *downLoader = self.downLoaderM[urlMD5];
    [downLoader cancelAndClean];
}

/**
 暂停全部
 */
- (void)pauseAll{
    [self.downLoaderM.allValues performSelector:@selector(pause) withObject:nil];
}

/**
 取消全部
 */
- (void)cancelAll{
    [self.downLoaderM.allValues performSelector:@selector(cancel) withObject:nil];
}

/**
 取消全部下载并且清除全部下载文件
 */
- (void)cancelAndCleanAll{
    [self.downLoaderM.allValues performSelector:@selector(cancelAndClean) withObject:nil];
}

-(void)resumeAll{
    [self.downLoaderM.allValues performSelector:@selector(resume) withObject:nil];
}
@end
