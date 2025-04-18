#import <audioapi/ios/AudioManagerModule.h>

#import <audioapi/ios/system/AudioEngine.h>
#import <audioapi/ios/system/AudioSessionManager.h>
#import <audioapi/ios/system/LockScreenManager.h>
#import <audioapi/ios/system/NotificationManager.h>

@implementation AudioManagerModule

RCT_EXPORT_MODULE(AudioManagerModule);

- (id)init
{
  if (self == [super init]) {
    self.audioEngine = [AudioEngine sharedInstance];
    self.audioSessionManager = [AudioSessionManager sharedInstance];
    self.notificationManager = [NotificationManager sharedInstance];
    self.lockScreenManager = [LockScreenManager sharedInstanceWithAudioManagerModule:self];
  }

  return self;
}

- (void)cleanup
{
  [self.audioEngine cleanup];
  [self.notificationManager cleanup];
  [self.audioSessionManager cleanup];
  [self.lockScreenManager cleanup];
}

- (void)dealloc
{
  [self cleanup];
}

RCT_EXPORT_METHOD(setLockScreenInfo : (NSDictionary *)info)
{
  [self.lockScreenManager setLockScreenInfo:info];
}

RCT_EXPORT_METHOD(resetLockScreenInfo)
{
  [self.lockScreenManager resetLockScreenInfo];
}

RCT_EXPORT_METHOD(enableRemoteCommand : (NSString *)name enabled : (BOOL)enabled)
{
  [self.lockScreenManager enableRemoteCommand:name enabled:enabled];
}

RCT_EXPORT_METHOD(setAudioSessionOptions : (NSString *)category mode : (NSString *)mode options : (NSArray *)
                      options active : (BOOL)active)
{
  NSError *error = nil;

  if (active) {
    [self.audioSessionManager setAudioSessionOptions:category mode:mode options:options];
  } else {
    [self.audioSessionManager setActive:false error:&error];
  }
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(getDevicePreferredSampleRate)
{
  return [self.audioSessionManager getDevicePreferredSampleRate];
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[
    @"onRemotePlay",
    @"onRemotePause",
    @"onRemoteStop",
    @"onRemoteTogglePlayPause",
    @"onRemoteChangePlaybackRate",
    @"onRemoteNextTrack",
    @"onRemotePreviousTrack",
    @"onRemoteSkipForward",
    @"onRemoteSkipBackward",
    @"onRemoteSeekForward",
    @"onRemoteSeekBackward",
    @"onRemoteChangePlaybackPosition"
  ];
}

- (void)sendEventWithValue:(NSString *)event withValue:(NSString *)value
{
  [self sendEventWithName:@"AudioManagerModule" body:@{@"name" : event, @"value" : value}];
}

@end
