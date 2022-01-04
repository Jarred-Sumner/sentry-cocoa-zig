#pragma once

#include <stdarg.h>
#include <stdbool.h>

typedef void (*sentry_on_crashed_last_run_callback)();
typedef void (*sentry_before_send_event_callback)(void *event);

typedef struct sentry_options_t {
  bool enabled;
  bool debug;
  bool enable_out_of_memory_tracking;
  bool enable_swizzling;
  const char *dsn;
  const char *release_name;
  sentry_before_send_event_callback on_before_send;
  sentry_on_crashed_last_run_callback on_crashed_last_run;
} sentry_options_t;

void sentry_startSentry(const sentry_options_t *options);
void sentry_captureMessage(const char *msg);
void sentry_stopSentry();
bool sentry_didCrashLastRun();
bool sentry_isEnabled();
void sentry_crash();
