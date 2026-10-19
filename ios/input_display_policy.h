#pragma once
#include <algorithm>
#include <cmath>
namespace pt::ios {
struct RenderSize { int width, height; };
inline RenderSize FitRenderWidth(int native_width, int native_height, int requested_width) {
    if (native_width<=0 || native_height<=0) return {std::max(2,requested_width),std::max(2,requested_width/2)};
    const int width=std::clamp(requested_width,2,native_width);
    if (width==native_width) return {native_width,native_height};
    const int height=std::clamp(static_cast<int>(std::lround(double(width)*native_height/native_width/2.0))*2,2,native_height);
    return {width,height};
}
struct StickValue { float x,y; };
inline StickValue TouchStick(float x,float y,bool look) {
    const float length=std::hypot(x,y);
    if (!std::isfinite(length) || length<=0.06f) return {0,0};
    const float magnitude=std::clamp((std::min(length,1.0f)-0.06f)/0.94f,0.0f,1.0f);
    // The right stick is a turn rate, with fine control near centre and a lower maximum.
    const float response=look?0.65f*std::pow(magnitude,1.6f):magnitude;
    return {x/length*response,y/length*response};
}
}
