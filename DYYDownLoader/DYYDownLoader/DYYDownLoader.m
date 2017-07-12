//
//  DYYDownLoader.m
//  DYYDownLoader
//
//  Created by yang on 2017/7/12.
//  Copyright © 2017年 dingyangyang. All rights reserved.
//

#import "DYYDownLoader.h"
#import "DYYFileManager.h"
#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define kTempPath NSTemporaryDirectory()
@interface DYYDownLoader()<NSURLSessionDataDelegate>
{
    long long _totalSize;
    long long _tempSize;
}
@property (nonatomic, strong)NSURLSession *session;
@property (nonatomic, copy)NSString *downLoadedPath;
@property (nonatomic, copy)NSString *downLoadingPath;
@property (nonatomic, strong)NSOutputStream *outputStream;
@property (nonatomic, weak)NSURLSessionDataTask *dataTask;

@end

@implementation DYYDownLoader
-(NSURLSession *)session {
    
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
    }
    return _session;
}

- (void)downloader:(NSURL *)url downLoadInfo:(DownLoadInfoBlockType)downLoadInfo progress:(ProgressBlockType)progress success:(SuccessBlockType)successBlock failed:(FailedBlockType)failedBlock{
    
    self.downLoadInfo = downLoadInfo;
    self.progressChange = progress;
    self.successBlock = successBlock;
    self.failedBlock = failedBlock;
    
    [self downloader:url];
}
- (void)downloader:(NSURL *)url{
    
    if ([url isEqual:self.dataTask.originalRequest.URL]) {
        //        if (self.state == YYDownLoadStateFailed) {
        //            self.state = YYDownLoadStatePause;
        //        }
        [self resume];
        return;
    }
    
    [self cancel];
    //    1.文件存放地址
    NSString *fileName = url.lastPathComponent;
    
    self.downLoadedPath = [kCachePath stringByAppendingPathComponent:fileName];
    self.downLoadingPath = [kTempPath stringByAppendingPathComponent:fileName];
    
    //    2.判断资源是否存在
    //    2.1cache存在下载完成
    if ([DYYFileManager fileExists:self.downLoadedPath]) {
        //文件存在 告诉外界信息
        self.state = DYYDownLoadStateSuccess;
        return;
    }
    
    //  2.2检测临时文件是否存在
    //    2.2不存在
    if (![DYYFileManager fileExists:self.downLoadingPath]) {
        //        从零开始下载
        _tempSize = 0;
        [self downLoadeWithUrl:url offset:_tempSize];
        return;
    }
    //存在
    _tempSize = [DYYFileManager fileSize:self.downLoadingPath];
    [self downLoadeWithUrl:url offset:_tempSize];
    
}

/**
 继续下载
 */
-(void)resume{
    if (self.dataTask && self.state == DYYDownLoadStatePause) {
        [self.dataTask resume];
        self.state = DYYDownLoadStateDownLoading;
    }
}

- (void)pause{
    if (self.state == DYYDownLoadStateDownLoading) {
        self.state = DYYDownLoadStatePause;
        [self.dataTask suspend];
    }
}
-(void)cancel{
    self.state = DYYDownLoadStatePause;
    [self.session invalidateAndCancel];
    self.session = nil;
    //        self.dataTask = nil;
    
}
-(void)cancelAndClean{
    [self cancel];
    [DYYFileManager removeFile:self.downLoadingPath];
}


#pragma mark - downLoaded offset
- (void)downLoadeWithUrl:(NSURL *)url offset:(long long)offset{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", offset] forHTTPHeaderField:@"Range"];
    
    
    // session 分配的task, 默认情况, 挂起状态
    self.dataTask = [self.session dataTaskWithRequest:request];
    
    [self resume];
}


#pragma mark - session delegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSHTTPURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
    //    response.allHeaderFields[@"Content-ize"]
    NSLog(@"%@",response);
    _totalSize = [response.allHeaderFields[@"Content-Length"] longLongValue];
    NSString *contentRangeStr = response.allHeaderFields[@"Content-Range"];
    if (contentRangeStr.length != 0) {
        _totalSize = [[contentRangeStr componentsSeparatedByString:@"/"].lastObject longLongValue];
    }
    if (self.downLoadInfo) {
        self.downLoadInfo(_totalSize);
    }
    if (_tempSize == _totalSize) {
        //下载完成 移动到 cache
        [DYYFileManager moveFile:self.downLoadingPath toPath:self.downLoadedPath];
        completionHandler(NSURLSessionResponseCancel);
        self.state = DYYDownLoadStateSuccess;
        return;
    }
    
    if (_tempSize > _totalSize) {
        //删除缓存 重新下载
        [DYYFileManager removeFile:self.downLoadingPath];
        self.state = DYYDownLoadStatePause;
        [self downloader:response.URL];
        completionHandler(NSURLSessionResponseCancel);
        return;
    }
    self.state = DYYDownLoadStateDownLoading;
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.downLoadingPath append:YES];
    [self.outputStream open];
    
    completionHandler(NSURLSessionResponseAllow);
    
}
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    _tempSize += data.length;
    self.progress = 1.0 * _tempSize / _totalSize;
    [self.outputStream write:data.bytes maxLength:data.length];
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    
    if (error) {
        // 取消,  断网
        // 999 != 999
        if (-999 == error.code) {
            self.state = DYYDownLoadStatePause;
        }else {
            self.state = DYYDownLoadStateFailed;
        }
    }else{
        
        [DYYFileManager moveFile:self.downLoadingPath toPath:self.downLoadedPath];
        self.state = DYYDownLoadStateSuccess;
        //判断temp大小是否等于总大小
        //判断文件MD5
        //移动到cache
        
    }
    [self.outputStream close];
}
#pragma mark - 数据
-(void)setState:(DYYDownLoadState)state{
    
    if (_state == state) {
        return;
    }
    _state = state;
    if (self.stateChange) {
        self.stateChange(_state);
    }
    
    if (_state == DYYDownLoadStateSuccess && self.successBlock) {
        self.successBlock(self.downLoadedPath);
    }
    if (_state == DYYDownLoadStateFailed && self.failedBlock) {
        self.failedBlock();
    }
    
    
    
}
-(void)setProgress:(float)progress{
    
    _progress = progress;
    if (self.progressChange) {
        self.progressChange(_progress);
    }
}
@end

