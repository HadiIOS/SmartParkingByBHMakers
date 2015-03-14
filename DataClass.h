//
//  DataClass.h
//  SmartParking
//
//  Created by Academy387 on 14/03/15.
//  Copyright (c) 2015 Academy387. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataClass : NSObject {
    
    NSString *token;
    NSArray *parkingData;
    int index;
    
}

@property(nonatomic,retain)NSString *token;
@property(nonatomic,retain)NSArray *parkingData;
@property int index;
+(DataClass*)getInstance;

@end

