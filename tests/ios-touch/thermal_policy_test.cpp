#include "../../ios/thermal_policy.h"
#include <cassert>
int main() {
    pt::ios::ThermalPolicy p;
    assert(p.FrameLimit(0,0,false,0)==120);
    assert(p.FrameLimit(120,0,false,1)==120);
    assert(p.FrameLimit(240,0,false,1.5)==120);
    assert(p.FrameLimit(24,0,false,2)==24);
    assert(p.FrameLimit(60,2,false,10)==30);
    assert(p.FrameLimit(60,0,false,69)==30);
    assert(p.FrameLimit(60,1,false,72)==30);
    assert(p.FrameLimit(60,0,false,73)==60);
    assert(p.FrameLimit(60,3,false,75)==30);
    assert(p.FrameLimit(20,3,false,76)==20);
    assert(p.FrameLimit(60,0,true,150)==30);
    assert(p.FrameLimit(60,0,false,209)==30);
    assert(p.FrameLimit(60,0,false,210)==60);
}
