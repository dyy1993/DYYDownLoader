//
//  DYYFileManager.m
//  DYYDownLoader
//
//  Created by yang on 2017/7/12.
//  Copyright © 2017年 dingyangyang. All rights reserved.
//

#import "DYYFileManager.h"

@implementation DYYFileManager
+ (BOOL)fileExists:(NSString *)filePath{
    
    if (filePath.length == 0) {
        return NO;
    }
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
}
+ (long long)fileSize:(NSString *)filePath{
    if (![self fileExists:filePath]) {
        return 0;
    }
    
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    return [fileInfo[NSFileSize] longLongValue];
}
+ (void)moveFile:(NSString *)atPath toPath:(NSString *)toPath{
    if (![self fileExists:atPath]) {
        return;
    }
    [[NSFileManager defaultManager] moveItemAtPath:atPath toPath:toPath error:nil];
    
}
+ (void)removeFile:(NSString *)filePath{
    if (![self fileExists:filePath]) {
        return;
    }
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    
}
@end
