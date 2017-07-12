//
//  ViewController.m
//  DYYDownLoader
//
//  Created by yang on 2017/7/12.
//  Copyright © 2017年 dingyangyang. All rights reserved.
//

#import "ViewController.h"
#import "DYYDownLoaderManager.h"

@interface ViewController ()
@property (nonatomic, strong)DYYDownLoader *downLoader;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView2;
@end

@implementation ViewController

-(DYYDownLoader *)downLoader{
    
    if (!_downLoader) {
        _downLoader = [[DYYDownLoader alloc] init];
    }
    return _downLoader;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.downLoader.stateChange = ^(DYYDownLoadState state) {
        NSLog(@"下载状态 %zd",state);
    };
}

- (IBAction)downLoad:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4"];
    [[DYYDownLoaderManager shareManager] downloader:url downLoadInfo:^(long long totalSize) {
        NSLog(@"文件大小  %lld",totalSize);
    } progress:^(float progress) {
        NSLog(@"下载进度  %f",progress);
        self.progressView.progress = progress;
    } success:^(NSString *filePath) {
        NSLog(@"下载完成   %@",filePath);
    } failed:^{
        NSLog(@"失败");
    }];
    NSURL *url2 = [NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_02.mp4"];
    [[DYYDownLoaderManager shareManager] downloader:url2 downLoadInfo:^(long long totalSize) {
        NSLog(@"文件大小  %lld",totalSize);
    } progress:^(float progress) {
        NSLog(@"下载进度  %f",progress);
        self.progressView2.progress = progress;
    } success:^(NSString *filePath) {
        NSLog(@"下载完成   %@",filePath);
    } failed:^{
        NSLog(@"失败");
    }];
    
}
- (IBAction)pause:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4"];
    [[DYYDownLoaderManager shareManager] pauseWithUrl:url];
}
- (IBAction)cancel:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4"];
    [[DYYDownLoaderManager shareManager] cancelWithUrl:url];
}
- (IBAction)cancleAndClean:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4"];
    [[DYYDownLoaderManager shareManager] cancelAndCleanWithUrl:url];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}

@end
