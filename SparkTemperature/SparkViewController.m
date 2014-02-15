//
//  SparkViewController.m
//  SparkTemperature
//
//  Created by ramin on 2/15/14.
//  Copyright (c) 2014 maadotaa.com. All rights reserved.
//

#import "SparkViewController.h"
#define ACCESS_TOKEN @"YOUR_ACCESS_TOKEN_HERE"
#define CORE_ID @"YOUR_CORE_ID_HERE"

@interface SparkViewController () <NSURLSessionDataDelegate>

@property (strong, nonatomic) NSURLSession *session;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;

@end

@implementation SparkViewController



-(NSURLSession *) session {
    if (!_session) {
        NSLog(@"---- Lazy instantiation of session");
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        [sessionConfig setAllowsCellularAccess:YES];
        [sessionConfig setHTTPAdditionalHeaders:@{ @"Accept" : @"application/json" }];
        sessionConfig.timeoutIntervalForRequest = 4.0;
        _session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    }
    return _session;
}


-(void) readTemp {
    NSString *command = [NSString stringWithFormat:@"https://api.spark.io/v1/devices/%@/temperature?access_token=%@", CORE_ID, ACCESS_TOKEN];
    [[self.session dataTaskWithURL:[NSURL URLWithString:command]  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError* error1;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:data
                              options:kNilOptions
                              error:&error1];
        
        CGFloat temp = [json[@"result"] integerValue];
        temp = temp*3.3/4095;
        temp = (temp - .5)*100;
        temp = temp/100*180.+32;
        NSString *tempStr = [NSString stringWithFormat:@"Temperature = %2.1f", temp];
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            self.tempLabel.text = tempStr;
        });
        NSLog(@"Temperature = %2.1f", temp);
        
        if (error) {
            NSLog(@"Got error after sending command.   %@", error.description);
        }
    }] resume];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    NSTimer *readTimer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(readTemp) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:readTimer forMode:NSDefaultRunLoopMode];
    [readTimer fire];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
