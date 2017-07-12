//
//  DYYFileManager.h
//  DYYDownLoader
//
//  Created by yang on 2017/7/12.
//  Copyright © 2017年 dingyangyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DYYFileManager : NSObject

+ (BOOL)fileExists:(NSString *)filePath;
+ (long long)fileSize:(NSString *)filePath;
+ (void)moveFile:(NSString *)atPath toPath:(NSString *)toPath;
+ (void)removeFile:(NSString *)filePath;
@end
