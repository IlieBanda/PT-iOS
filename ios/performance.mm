#import <Foundation/Foundation.h>
#include <SDL3/SDL.h>
#include "thermal_policy.h"
int PTIOSFrameLimit(int requested) {
    static pt::ios::ThermalPolicy policy;
    static double next_poll = 0;
    static int thermal = 0;
    static bool low_power = false;
    const double now = SDL_GetTicksNS() * 1e-9;
    if (now >= next_poll) {
        NSProcessInfo* info = NSProcessInfo.processInfo;
        thermal = static_cast<int>(info.thermalState);
        low_power = info.lowPowerModeEnabled;
        next_poll = now + 1;
    }
    return policy.FrameLimit(requested, thermal, low_power, now);
}
