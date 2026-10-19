#include <SDL3/SDL.h>
void PTIOSUseFullscreen(SDL_Window* window) {
    if (!window) return;
    SDL_SetWindowFullscreenMode(window, nullptr);
    if (!(SDL_GetWindowFlags(window) & SDL_WINDOW_FULLSCREEN) && !SDL_SetWindowFullscreen(window, true)) {
        SDL_Log("ios: could not restore fullscreen: %s", SDL_GetError());
    }
}
