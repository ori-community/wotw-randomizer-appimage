#include <cstdlib>
#include <cstdio>
#include <cstring>
#include <format>
#include <iostream>
#include <libgen.h>
#include <unistd.h>

void set_env(const std::string& name, const std::string& value) {
    std::string new_env(std::format("{}={}", name, value));
    putenv(new_env.data());
}

int main(int argc, char* argv[]) {
    const char* appdir = dirname(realpath("/proc/self/exe", nullptr));

    if (!appdir) {
        std::cout << "Could not read /proc/self/exe" << std::endl;
        return 1;
    }

    std::cout << "Setting up environment..." << std::endl;
    set_env(
        "LD_LIBRARY_PATH",
        std::format(
            "{0}/usr/lib/:{0}/usr/lib/i386-linux-gnu/:{0}/usr/lib/x86_64-linux-gnu/:{0}/usr/lib32/:{0}/usr/lib64/:{0}/lib/:{0}/lib/i386-linux-gnu/:{0}/lib/x86_64-linux-gnu/:{0}/lib32/:{0}/lib64/:{1}",
            appdir,
            getenv("LD_LIBRARY_PATH") ? : ""
        )
    );

    set_env(
        "PATH",
        std::format(
            "{0}/opt/wine/bin/:{1}",
            appdir,
            getenv("PATH") ? : ""
        )
    );

    set_env("WOTW_RANDOMIZER_APPIMAGE_ROOT", appdir);

    const std::string executable_path(std::format("{}/opt/wotw-randomizer/Ori and the Will of the Wisps Randomizer", appdir));
    std::cout << std::format("Executing '{}'", executable_path) << std::endl;
    const int return_code = execvp(executable_path.c_str(), argv);
    const int error_code = errno;

    if (return_code == -1) {
        std::cout << std::format("Failed to execute: {}", std::strerror(error_code)) << std::endl;
    }

    return return_code;
}
