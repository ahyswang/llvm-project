#ifndef LLNMLIR_VERSION_H
#define LLNMLIR_VERSION_H

namespace ttmlir {

#ifndef LLNMLIR_GIT_HASH
#error "LLNMLIR_GIT_HASH must be defined"
#endif
#ifndef LLNMLIR_VERSION_MAJOR
#error "LLNMLIR_VERSION_MAJOR must be defined"
#endif
#ifndef LLNMLIR_VERSION_MINOR
#error "LLNMLIR_VERSION_MINOR must be defined"
#endif
#ifndef LLNMLIR_VERSION_PATCH
#error "LLNMLIR_VERSION_PATCH must be defined"
#endif

struct Version {
  unsigned major;
  unsigned minor;
  unsigned patch;

  constexpr Version(unsigned major, unsigned minor, unsigned patch)
      : major(major), minor(minor), patch(patch) {}

  constexpr bool operator<=(const Version &other) const {
    return major < other.major ||
           (major == other.major && (minor <= other.minor));
  }

  constexpr bool operator>=(const Version &other) const {
    return major > other.major ||
           (major == other.major && (minor >= other.minor));
  }
};

inline constexpr Version getVersion() {
  return Version(LLNMLIR_VERSION_MAJOR, LLNMLIR_VERSION_MINOR,
                 LLNMLIR_VERSION_PATCH);
}

#define XSTR(s) STR(s)
#define STR(s) #s
inline constexpr const char *getGitHash() { return XSTR(LLNMLIR_GIT_HASH); }
#undef STR
#undef XSTR

} // namespace ttmlir
#endif