//
//  ViewController.m
//  ControlLed
//
//  Created by Phan Nhu on 12/19/15.
//  Copyright © 2015 MFM. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) UIButton * buttonOnOff;
@property (nonatomic, strong) UILabel * labelStatus;
@end

@implementation ViewController
{
    BOOL isOn;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.buttonOnOff = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    self.buttonOnOff.center = self.view.center;
    self.buttonOnOff.backgroundColor = [UIColor grayColor];
    self.buttonOnOff.layer.cornerRadius = 5;
    [self.buttonOnOff setTitle:@"ON/OFF" forState:UIControlStateNormal];
    [self.buttonOnOff addTarget:self action:@selector(didTapOnOff:) forControlEvents:UIControlEventTouchUpInside];
    
    self.labelStatus = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 300, 50)];
    self.labelStatus.text = @"Off";
    self.labelStatus.textAlignment = NSTextAlignmentCenter;
    isOn = NO;
    
    [self.view addSubview:self.buttonOnOff];
    [self.view addSubview:self.labelStatus];
    
}

- (void)didTapOnOff:(UIButton *)button
{
    isOn = !isOn;
    self.labelStatus.text = isOn ? @"ON": @"OFF";
}

@end
