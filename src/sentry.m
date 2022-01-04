
#include "sentry.h"
#include <Foundation/Foundation.h>
#include <sentry/Sentry.h>

static sentry_before_send_event_callback _on_before_send_callback;
static sentry_on_crashed_last_run_callback _on_crashed_last_run_callback;
void sentry_startSentry(const sentry_options_t *options) {
  SentryOptions *_options = [[SentryOptions alloc] init];
  [_options setEnabled:options->enabled];
  [_options setDebug:options->debug];
  _options.dsn = [NSString stringWithUTF8String:options->dsn];
  [_options setEnableSwizzling:false];
  [_options setEnableAutoSessionTracking:false];
  [_options setEnableAutoPerformanceTracking:false];
  [_options setEnableNetworkTracking:false];
  [_options setEnableOutOfMemoryTracking:false];

  [_options
      setReleaseName:[NSString stringWithUTF8String:options->release_name]];

  if (options->on_before_send) {
    // copy it so we don't worry about allocation
    _on_before_send_callback = options->on_before_send;
    _options.beforeSend = ^(SentryEvent *event) {
      if (_on_before_send_callback) {
        _on_before_send_callback(event);
      }

      return event;
    };
  }

  if (options->on_crashed_last_run) {
    // copy it so we don't worry about allocation
    _on_crashed_last_run_callback = options->on_crashed_last_run;
    _options.onCrashedLastRun = ^(SentryEvent *event) {
      if (_on_crashed_last_run_callback) {
        _on_crashed_last_run_callback();
      }
    };
  }

  [SentrySDK startWithOptionsObject:_options];
  [SentrySDK startSession];
}
void sentry_stopSentry() { [SentrySDK close]; }
bool sentry_didCrashLastRun() { return [SentrySDK crashedLastRun]; }
void sentry_crash() { [SentrySDK crash]; }
bool sentry_isEnabled() { return [SentrySDK isEnabled]; }

void sentry_captureMessage(const char *msg) {
  [SentrySDK captureMessage:[NSString stringWithUTF8String:msg]];
}