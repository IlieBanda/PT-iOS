#pragma once
#include <algorithm>
namespace pt::ios {
// NSProcessInfoThermalState: nominal=0, fair=1, serious=2, critical=3.
struct ThermalPolicy {
    bool reduced = false;
    double recover_after = 0;
    int FrameLimit(int requested, int thermal, bool low_power, double now) {
        if (thermal >= 2 || low_power) {
            reduced = true;
            recover_after = now + 60;
        } else if (reduced && thermal == 0 && now >= recover_after) {
            reduced = false;
        }
        return std::min(requested > 0 ? requested : 120, reduced ? 30 : 120);
    }
};
}
