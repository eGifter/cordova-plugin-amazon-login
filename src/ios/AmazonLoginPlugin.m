#import "AmazonLoginPlugin.h"
#import "AppDelegate.h"
#import <objc/runtime.h>
#import <Cordova/CDVAvailability.h>
#import <LoginWithAmazon/LoginWithAmazon.h>

#pragma mark - AppDelegate Overrides

@implementation AppDelegate (AmazonLogin)

// implemented swizzling approach from https://github.com/jeduan/cordova-plugin-facebook4
    
void AMZNMethodSwizzle(Class c, SEL originalSelector) {
    NSString *selectorString = NSStringFromSelector(originalSelector);
    SEL newSelector = NSSelectorFromString([@"swizzled_" stringByAppendingString:selectorString]);
    SEL noopSelector = NSSelectorFromString([@"noop_" stringByAppendingString:selectorString]);
    Method originalMethod, newMethod, noop;
    originalMethod = class_getInstanceMethod(c, originalSelector);
    newMethod = class_getInstanceMethod(c, newSelector);
    noop = class_getInstanceMethod(c, noopSelector);
    if (class_addMethod(c, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(c, newSelector, method_getImplementation(originalMethod) ?: method_getImplementation(noop), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}
    
+ (void)load
{
    AMZNMethodSwizzle([self class], @selector(application:openURL:sourceApplication:annotation:));
}
    
// This method is a duplicate of the other openURL method below, except using the newer iOS (9) API.
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    if (!url) {
        return NO;
    }

    NSLog(@"AMZN handle url: %@", url);
    return
        [AMZNAuthorizationManager handleOpenURL:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]]
        || [self swizzled_application:application openURL:url sourceApplication:[options valueForKey:@"UIApplicationOpenURLOptionsSourceApplicationKey"] annotation:0x0];
}
    
- (BOOL)noop_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return NO;
}
    
- (BOOL)swizzled_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (!url) {
        return NO;
    }
    
    NSLog(@"AMZN handle url: %@", url);
    return
        [AMZNAuthorizationManager handleOpenURL:url sourceApplication:sourceApplication]
        || [self swizzled_application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

@end

@implementation AmazonLoginPlugin

- (void)authorize:(CDVInvokedUrlCommand *)command {
        // NSLog(@"AmazonLoginPlugin authorize request started");
        // Build an authorize request.
        AMZNAuthorizeRequest *request = [[AMZNAuthorizeRequest alloc] init];
        request.scopes = [NSArray arrayWithObjects:
                          [AMZNProfileScope userID],
                          [AMZNProfileScope profile],
                          [AMZNProfileScope postalCode], nil];

        // Make an Authorize call to the Login with Amazon SDK.
        [[AMZNAuthorizationManager sharedManager] authorize:request
                                                withHandler:^(AMZNAuthorizeResult *result, BOOL
                                                              userDidCancel, NSError *error) {
                                                    if (error) {
                                                        // Handle errors from the SDK or authorization server.
                                                        if(error.code == kAIApplicationNotAuthorized) {
                                                            // Show authorize user button.
                                                            // NSLog(@"AmazonLoginPlugin authorize request NotAuthorized");

                                                            NSString* payload =@"authorize request NotAuthorized";

                                                            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:payload];

                                                            // The sendPluginResult method is thread-safe.
                                                            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];


                                                        } else {
                                                            // NSLog(@"AmazonLoginPlugin authorize request failed");
                                                            NSString* payload = error.userInfo[@"AMZNLWAErrorNonLocalizedDescription"];

                                                            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:payload];

                                                            // The sendPluginResult method is thread-safe.
                                                            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                                        }



                                                    } else if (userDidCancel) {
                                                        // Handle errors caused when user cancels login.
                                                        // NSLog(@"AmazonLoginPlugin authorize request canceled");
                                                       NSString* payload = @"authorize request canceled";


                                                        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:payload];

                                                        // The sendPluginResult method is thread-safe.
                                                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];


                                                    } else {
                                                        // NSLog(@"AmazonLoginPlugin authorize success");
                                                        // Authentication was successful.

                                                        NSDictionary *dictionary = @{
                                                                                     @"accessToken": result.token,
                                                                                     @"user": result.user.profileData
                                                                                     };


                                                        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dictionary];

                                                        // The sendPluginResult method is thread-safe.
                                                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                                    }
                                                }];
}

- (void)fetchUserProfile:(CDVInvokedUrlCommand *)command {
    //NSLog(@"AmazonLoginPlugin fetchUserProfile");

    [AMZNUser fetch:^(AMZNUser *user, NSError *error) {
        if (error) {
            // Error from the SDK, or no user has authorized to the app.
            NSString* payload = error.userInfo[@"AMZNLWAErrorNonLocalizedDescription"];

            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:payload];

            // The sendPluginResult method is thread-safe.
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        } else if (user) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:user.profileData];

            // The sendPluginResult method is thread-safe.
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        }
    }];
}

- (void)getToken:(CDVInvokedUrlCommand *)command {
   // NSLog(@"AmazonLoginPlugin  getToken");
   // Build an authorize request.
          AMZNAuthorizeRequest *request = [[AMZNAuthorizeRequest alloc] init];
          request.scopes = [NSArray arrayWithObjects:
                            [AMZNProfileScope userID],
                            [AMZNProfileScope profile],
                            [AMZNProfileScope postalCode], nil];

          request.interactiveStrategy = AMZNInteractiveStrategyNever;


          // Make an Authorize call to the Login with Amazon SDK.
          [[AMZNAuthorizationManager sharedManager] authorize:request
                                                  withHandler:^(AMZNAuthorizeResult *result, BOOL
                                                                userDidCancel, NSError *error) {
                                                      if (error) {
                                                          // Handle errors from the SDK or authorization server.
                                                          if(error.code == kAIApplicationNotAuthorized) {
                                                              // Show authorize user button.
                                                              //NSLog(@"AmazonLoginPlugin authorize request NotAuthorized");

                                                              NSString* payload =@"authorize request NotAuthorized";

                                                              CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:payload];

                                                              // The sendPluginResult method is thread-safe.
                                                              [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];


                                                          } else {
                                                              //NSLog(@"AmazonLoginPlugin authorize request failed");
                                                              NSString* payload = error.userInfo[@"AMZNLWAErrorNonLocalizedDescription"];

                                                              CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:payload];

                                                              // The sendPluginResult method is thread-safe.
                                                              [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                                          }
                                                      } else if (userDidCancel) {
                                                          // Handle errors caused when user cancels login.
                                                          // NSLog(@"AmazonLoginPlugin authorize request canceled");
                                                          NSString* payload = @"authorize request canceled";

                                                          CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:payload];

                                                          // The sendPluginResult method is thread-safe.
                                                          [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                                      } else {
                                                          // NSLog(@"AmazonLoginPlugin authorize success");
                                                          // Authentication was successful.

                                                          NSDictionary *dictionary = @{
                                                                                       @"accessToken": result.token,
                                                                                       @"user": result.user.profileData
                                                                                       };


                                                          CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dictionary];

                                                          // The sendPluginResult method is thread-safe.
                                                          [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                                      }
                                                  }];
}

- (void)signOut:(CDVInvokedUrlCommand *)command {
    //NSLog(@"AmazonLoginPlugin signOut");
    [[AMZNAuthorizationManager sharedManager] signOut:^(NSError * _Nullable error) {
        if (!error) {
            // error from the SDK or Login with Amazon authorization server.
            NSString* payload = error.userInfo[@"AMZNLWAErrorNonLocalizedDescription"];

            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:payload];

            // The sendPluginResult method is thread-safe.
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
}
@end
