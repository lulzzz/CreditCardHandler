//
//  FlightVO.h
//  PaymentServiceAPI
//
//  Created by Peter Qiu on 9/26/14.
//  Copyright (c) 2014 Peter Qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeneralInfoVO : NSObject
{
    int _companyId;
    int _crewId;
    NSString * _deviceId;
    NSDate *_departureTime;
    NSString * _flightNum;
    NSString * _originatingAirport;
    NSString * _destinationAirport;
    
}
@property (nonatomic, assign) int companyId;
@property (nonatomic, assign) int crewId;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSDate *DepartureTime;
@property (nonatomic, copy) NSString *FlightNum;
@property (nonatomic, copy) NSString *OriginatingAirport;
@property (nonatomic, copy) NSString *DestinationAirport;

- (id)initWithName: (int)companyId crewId:(int)crewId deviceId:(NSString *)deviceId depTime:(NSDate *)depTime fltNum:(NSString *)fltNum origAiport:(NSString *)origAiport destAirport:(NSString *)destAirport;

@end
