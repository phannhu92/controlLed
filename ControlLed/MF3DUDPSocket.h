//
//  MF3DUDPSocket.h
//  3DMotion-Mega
//
//  Created by Hai Phan on 11/24/15.
//  Copyright © 2015 Misfit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MF3DUDPSocket : NSObject
+ (MF3DUDPSocket *)shareInstance;
- (void)setupUDP;
@end
