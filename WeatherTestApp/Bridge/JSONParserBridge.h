// JSONParserBridge.h
// WeatherTestApp
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeatherCurrentObjC : NSObject
@property (nonatomic, assign) double temperature;
@property (nonatomic, assign) double feelsLike;
@property (nonatomic, assign) int pressure;
@property (nonatomic, assign) int humidity;
@property (nonatomic, assign) int visibility;
@property (nonatomic, assign) int cloudiness;
@property (nonatomic, strong) NSString *weatherDescription;
@property (nonatomic, strong) NSString *iconCode;
@end

@interface WeatherDailyObjC : NSObject
@property (nonatomic, assign) double timestamp;
@property (nonatomic, assign) double tempDay;
@property (nonatomic, assign) double tempMin;
@property (nonatomic, assign) double tempMax;
@property (nonatomic, assign) int pressure;
@property (nonatomic, assign) int humidity;
@property (nonatomic, assign) int cloudiness;
@property (nonatomic, strong) NSString *weatherDescription;
@property (nonatomic, strong) NSString *iconCode;
@end

@interface JSONParserBridge : NSObject

/// Parses /data/2.5/weather response (current weather).
+ (nullable WeatherCurrentObjC *)parseCurrentWeatherData:(NSData *)data
                                                   error:(NSError *_Nullable *_Nullable)error;

/// Parses /data/2.5/forecast response (3-hour steps, 5 days).
/// Groups entries by calendar day and returns daily aggregates.
+ (nullable NSArray<WeatherDailyObjC *> *)parseForecastData:(NSData *)data
                                                      error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
