#include "../../ios/input_display_policy.h"
#include <cassert>
#include <cstdio>
#include <limits>
int main() {
    using namespace pt::ios;
    for (auto native : {RenderSize{2622,1206},RenderSize{2556,1179},RenderSize{2868,1320},RenderSize{2048,1536}}) {
        for (int w : {854,960,1280,1600,1920,native.width,9999}) {
            auto r=FitRenderWidth(native.width,native.height,w);
            assert(r.width<=native.width && r.height<=native.height);
            assert(std::abs(double(r.width)*native.height/native.width-r.height)<=1.01);
        }
        auto r=FitRenderWidth(native.width,native.height,native.width);
        assert(r.width==native.width && r.height==native.height);
    }
    auto r=FitRenderWidth(2622,1206,1600); assert(r.width==1600 && r.height==736);
    assert(TouchStick(0,0,true).x==0 && TouchStick(.03f,.03f,true).y==0);
    float previous=0;
    for (int i=7;i<=100;++i) { auto s=TouchStick(i/100.f,0,true); assert(s.x>=previous && s.x<=.65001f);previous=s.x; }
    auto diagonal=TouchStick(1,1,true);assert(std::abs(std::hypot(diagonal.x,diagonal.y)-.65f)<.0001f);
    assert(TouchStick(.2f,0,true).x>0 && TouchStick(.2f,0,true).x<TouchStick(.2f,0,false).x);
    assert(TouchStick(std::numeric_limits<float>::quiet_NaN(),0,true).x==0);
    assert(TouchStick(std::numeric_limits<float>::infinity(),1,true).y==0);
    puts("PASS: drawable aspect, bounded/native sizes, radial dead zone, monotonic fine look, diagonal bound, invalid input");
}
