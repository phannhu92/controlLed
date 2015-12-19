//
//  MF3DUDPSocket.m
//  3DMotion-Mega
//
//  Created by Hai Phan on 11/24/15.
//  Copyright © 2015 Misfit. All rights reserved.
//

#import "MF3DUDPSocket.h"

#import <CocoaAsyncSocket.h>


static NSString * url = @"239.255.255.255";
static NSInteger port = 10552;

@interface MF3DUDPSocket()<GCDAsyncUdpSocketDelegate>
@property (nonatomic, strong) GCDAsyncUdpSocket * udpSocket;
@end

@implementation MF3DUDPSocket
{
    NSInteger counter;
    NSMutableArray * sensorDatas;
}
+ (MF3DUDPSocket *)shareInstance
{
    static MF3DUDPSocket *_shareInstance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _shareInstance = [[MF3DUDPSocket alloc] init];
    });
    return _shareInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        counter = 0;
        sensorDatas = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUDP
{
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    if (![self.udpSocket bindToPort:port error:&error])
    {
        NSLog(@"Error binding to port: %@", error);
        return;
    }
    
    if(![self.udpSocket joinMulticastGroup: url error:&error]){
        NSLog(@"Error connecting to multicast group: %@", error);
        return;
    }
    if (![self.udpSocket beginReceiving:&error])
    {
        NSLog(@"Error receiving: %@", error);
        return;
    }
    NSLog(@"Socket Ready");}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    counter++;
    NSLog(@"Count: %@", @(counter));
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray * array = [msg componentsSeparatedByString:@","];
    
    NSString *host = nil;
    uint16_t port = 0;
    
    [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
    double value13 = [array[13] doubleValue];
    
    if (value13 <= 0)
    {
        return;
    }
    
    if (msg)
    {
        
        NSDictionary * sensorData = @{@"ax":@([array[1] doubleValue]),
                                      @"ay":@([array[2] doubleValue]),
                                      @"az":@([array[3] doubleValue]),
                                      @"gx":@([array[8] doubleValue]),
                                      @"gy":@([array[9] doubleValue]),
                                      @"gz":@([array[10] doubleValue]),
                                      @"mx":@([array[14] doubleValue]),
                                      @"my":@([array[15] doubleValue]),
                                      @"mz":@([array[16] doubleValue]),
                                      
                                      @"q0":@([array[4] doubleValue]),
                                      @"q1":@([array[5] doubleValue]),
                                      @"q2":@([array[6] doubleValue]),
                                      @"qw":@([array[7] doubleValue])};
        
//        [sensorDatas addObject:sensorData];
        
        
//        double acc[3] = {[array[1] doubleValue], [array[2] doubleValue], [array[3] doubleValue]};
//        double gyro[3] = {[array[8] doubleValue], [array[9] doubleValue], [array[10] doubleValue]};
//        double magn[3] = {[array[14] doubleValue], [array[15] doubleValue], [array[16] doubleValue]};
//        
//        msl_m3d_process_data(1.0/20, acc, gyro, magn);
//        NSDictionary * sensorData = @{
//                                      @"acc-gyro-magn":[NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@",
//                                                            @(acc[0]),@(acc[1]),@(acc[2]),@(gyro[0]),@(gyro[1]),@(gyro[2]),@(magn[0]),@(magn[1]),@(magn[2])],
//                                      @"acc":@[@(acc[0]),@(acc[1]),@(acc[2])],
//                                      @"gyro":@[@(gyro[0]),@(gyro[1]),@(gyro[2])],
//                                      @"magn":@[@(magn[0]),@(magn[1]),@(magn[2])],
//                                      
//                                      @"apple_q0":@([array[4] doubleValue]),
//                                      @"apple_q1":@([array[5] doubleValue]),
//                                      @"apple_q2":@([array[6] doubleValue]),
//                                      @"apple_qw":@([array[7] doubleValue]),
//                                      @"kalman_q0":@(q_kalman[1]),
//                                      @"kalman_q1":@(q_kalman[2]),
//                                      @"kalman_q2":@(q_kalman[3]),
//                                      @"kalman_qw":@(q_kalman[0]),
//                                      @"passive_q0":@(q_passive[1]),
//                                      @"passive_q1":@(q_passive[2]),
//                                      @"passive_q2":@(q_passive[3]),
//                                      @"passive_qw":@(q_passive[0]),
//                                      @"direct_q0":@(q_direct[1]),
//                                      @"direct_q1":@(q_direct[2]),
//                                      @"direct_q2":@(q_direct[3]),
//                                      @"direct_qw":@(q_direct[0]),
//                                      @"slerp_q0":@(q_slerp[1]),
//                                      @"slerp_q1":@(q_slerp[2]),
//                                      @"slerp_q2":@(q_slerp[3]),
//                                      @"slerp_qw":@(q_slerp[0])};
//        
        NSLog(@"sensor data : %@", sensorData);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kUDPSensorDataQuaternionNotification"
                                                            object:self
                                                           userInfo:sensorData];
    }
    else
    {
        NSLog(@"Error converting received data into UTF-8 String");
    }
    
//    if (counter == 100)
//    {
//        NSString * filePath = [[MMFDataHelper shareManager] createFilePathWithDate:[NSDate date]];
//        [[MMFDataHelper shareManager] writeDataSensor:sensorDatas toFilePath:filePath];
//    }
}

@end
