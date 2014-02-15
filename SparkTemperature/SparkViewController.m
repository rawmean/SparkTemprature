//
//  SparkViewController.m
//  SparkTemperature
//
//  Created by ramin on 2/15/14.
//  Copyright (c) 2014 maadotaa.com. All rights reserved.
//

#import "SparkViewController.h"
#import "MeterView.h"


#define ACCESS_TOKEN @"1740bb7a80b2f5b1095e974d68ab7f17e3d9af8a"
#define CORE_ID @"48ff72065067555041281587"

@interface SparkViewController () <NSURLSessionDataDelegate> {
    MeterView *needleView;
	MeterView *voltmeterView;
}

@property (strong, nonatomic) NSURLSession *session;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet MeterView *needleView;

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
        NSString *tempStr = [NSString stringWithFormat:@"Temperature = %2.1f F", temp];
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            self.tempLabel.text = tempStr;
            self.needleView.value = temp;
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
	self.needleView.textLabel.text = @"Fahrenheit";
	self.needleView.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:18.0];
	self.needleView.lineWidth = 2.5;
	self.needleView.minorTickLength = 15.0;
	self.needleView.needle.width = 3.0;
	self.needleView.textLabel.textColor = [UIColor colorWithRed:0.7 green:1.0 blue:1.0 alpha:1.0];
	self.needleView.textLabel.textColor = [UIColor whiteColor];
//	self.needleView.minNumber = 0.0;
//	self.needleView.minNumber = 120.0;
    
	self.needleView.value = 0.0;
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
