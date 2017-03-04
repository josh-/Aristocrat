//
//  JPLaunchAtLoginManager.h
//  Aristocrat
//
//  Created by Josh Parnham on 20/02/2017.
//  Copyright (c) 2017 Josh Parnham. All rights reserved.
//

#import <ServiceManagement/ServiceManagement.h>

@interface JPLaunchAtLoginManager : NSObject

+ (BOOL)willStartAtLogin:(NSString *)itemURL;
+ (void)setStartAtLogin:(NSString *)itemURL enabled:(BOOL)enabled;

@end
