// JSONParserBridge.mm
// WeatherTestApp

#import "JSONParserBridge.h"
#include "tao/json.hpp"
#include <map>
#include <vector>
#include <limits>
#include <cmath>
#include <algorithm>

// MARK: - Objective-C model implementations

@implementation WeatherCurrentObjC
@end

@implementation WeatherDailyObjC
@end

// MARK: - Helpers

static NSString *nsstring(const std::string &s) {
    return [NSString stringWithUTF8String:s.c_str()];
}

/// Returns the JSON value as double, supporting int/uint/double JSON types.
static double numericValue(const tao::json::value &v) {
    return v.as<double>();
}

static NSError *makeError(const std::string &msg) {
    return [NSError errorWithDomain:@"JSONParserBridgeError"
                               code:1
                           userInfo:@{NSLocalizedDescriptionKey: nsstring(msg)}];
}

// MARK: - Bridge

@implementation JSONParserBridge

// ──────────────────────────────────────────────────────────────────────────────
// Parse /data/2.5/weather  (current weather)
// ──────────────────────────────────────────────────────────────────────────────
+ (nullable WeatherCurrentObjC *)parseCurrentWeatherData:(NSData *)data
                                                   error:(NSError **)error {
    try {
        const std::string json(static_cast<const char *>(data.bytes), data.length);
        const auto root = tao::json::from_string(json);

        WeatherCurrentObjC *current = [[WeatherCurrentObjC alloc] init];

        const auto &main = root.at("main");
        current.temperature = numericValue(main.at("temp"));
        current.feelsLike   = numericValue(main.at("feels_like"));
        current.pressure    = static_cast<int>(numericValue(main.at("pressure")));
        current.humidity    = static_cast<int>(numericValue(main.at("humidity")));

        const auto *visPtr  = root.find("visibility");
        current.visibility  = visPtr ? static_cast<int>(numericValue(*visPtr)) : 10000;

        const auto *cloudsPtr = root.find("clouds");
        current.cloudiness = cloudsPtr
            ? static_cast<int>(numericValue(cloudsPtr->at("all")))
            : 0;

        const auto &wx = root.at("weather").get_array();
        if (!wx.empty()) {
            current.weatherDescription = nsstring(wx[0].at("description").get_string());
            current.iconCode           = nsstring(wx[0].at("icon").get_string());
        } else {
            current.weatherDescription = @"";
            current.iconCode           = @"";
        }

        return current;

    } catch (const std::exception &e) {
        if (error) { *error = makeError(e.what()); }
        return nil;
    } catch (...) {
        if (error) { *error = makeError("Unknown C++ exception"); }
        return nil;
    }
}

// ──────────────────────────────────────────────────────────────────────────────
// Parse /data/2.5/forecast  (3-hour steps, 5 days)
// Groups by calendar day and returns daily aggregates (up to 6 days).
// ──────────────────────────────────────────────────────────────────────────────
+ (nullable NSArray<WeatherDailyObjC *> *)parseForecastData:(NSData *)data
                                                      error:(NSError **)error {
    try {
        const std::string json(static_cast<const char *>(data.bytes), data.length);
        const auto root = tao::json::from_string(json);

        const auto &list = root.at("list").get_array();

        // Group entries by unix day (dt / 86400)
        std::map<int, std::vector<const tao::json::value *>> groups;
        for (const auto &entry : list) {
            int day = static_cast<int>(numericValue(entry.at("dt"))) / 86400;
            groups[day].push_back(&entry);
        }

        NSMutableArray<WeatherDailyObjC *> *daily = [NSMutableArray array];

        for (const auto &[dayKey, entries] : groups) {
            double tempMin    =  std::numeric_limits<double>::max();
            double tempMax    = -std::numeric_limits<double>::max();
            double pressureSum = 0, humiditySum = 0, cloudsSum = 0;

            for (const auto *e : entries) {
                const auto &m = e->at("main");
                tempMin = std::min(tempMin, numericValue(m.at("temp_min")));
                tempMax = std::max(tempMax, numericValue(m.at("temp_max")));
                pressureSum += numericValue(m.at("pressure"));
                humiditySum += numericValue(m.at("humidity"));
                const auto *clouds = e->find("clouds");
                cloudsSum += clouds ? numericValue(clouds->at("all")) : 0;
            }

            int count = static_cast<int>(entries.size());

            // Pick the middle entry as representative (closest to midday)
            const tao::json::value *rep = entries[count / 2];

            WeatherDailyObjC *day = [[WeatherDailyObjC alloc] init];
            day.timestamp  = numericValue(rep->at("dt"));
            day.tempDay    = numericValue(rep->at("main").at("temp"));
            day.tempMin    = tempMin;
            day.tempMax    = tempMax;
            day.pressure   = static_cast<int>(std::round(pressureSum / count));
            day.humidity   = static_cast<int>(std::round(humiditySum / count));
            day.cloudiness = static_cast<int>(std::round(cloudsSum / count));

            const auto &wx = rep->at("weather").get_array();
            if (!wx.empty()) {
                day.weatherDescription = nsstring(wx[0].at("description").get_string());
                day.iconCode           = nsstring(wx[0].at("icon").get_string());
            } else {
                day.weatherDescription = @"";
                day.iconCode           = @"";
            }

            [daily addObject:day];
        }

        return daily;

    } catch (const std::exception &e) {
        if (error) { *error = makeError(e.what()); }
        return nil;
    } catch (...) {
        if (error) { *error = makeError("Unknown C++ exception"); }
        return nil;
    }
}

@end
