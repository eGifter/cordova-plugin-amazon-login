# Cordova Plugin Login with Amazon

A Cordova Plugin for Login with Amazon. Use your Amazon account to authenticate with the app.
This plugin is a wrapper around native android and iOS libraries developed by Amazon.
 
##Prerequisites

### Android

- Download the [Amazon Mobile App SDK](https://developer.amazon.com/public/resources/development-tools/sdk)  and extract the files to a directory on your hard drive.
- You should see a `login-with-amazon.jar` file in the LoginWithAmazon parent directory.
- Copy `login-with-amazon.jar` file to `platforms/android/libs/login-with-amazon.jar` of your Cordova project.
- Create configuration file for Amazon API keys `config\project.json`
- If you do not have your API Key yet, see [Android App Signatures and API Keys](https://developer.amazon.com/public/apis/engage/login-with-amazon/docs/register_android.html#Android%20App%20Signatures%20and%20API%20Keys) and follow the instructions under "Retrieving an Android API Key".
- Set your Amazon API keys in `config\project.json`

For example, your `config\project.json` might look like this:

```
{
  "debug":
  {
    "AMAZON_API_KEY" : "hdgGHHDG......8yRM=="
  },
  "release":
  {
    "AMAZON_API_KEY" : "dh8HGuDQ......rt5H=="
  }
}
```


By default, the value of API key from `debug` section will be used.
In order to use API key from `release` section 

```
TARGET=release cordova prepare
```

### iOS

- If you have not installed Xcode, you can get it from https://developer.apple.com/xcode.
- Download the [Amazon Mobile App SDK] (https://developer.amazon.com/public/resources/development-tools/sdk) and extract the files to a directory on your hard drive.
- You should see a LoginWithAmazon.framework directory in the LoginWithAmazon parent directory. This contains the Login with Amazon library.
- With your project open in Xcode, select the Frameworks folder, then click File from the main menu and select Add Files to "project". In the dialog, select LoginWithAmazon.framework and click Add. 
- Select Build Settings. Click All to view all settings.
- Under Search Paths, ensure that the LoginWithAmazon.framework directory is in the Framework Search Paths. For example:
- In the main menu, click Product and select Build. The build should complete successfully.
- [Add a URL Scheme to Your App Property List](https://developer.amazon.com/public/apis/engage/login-with-amazon/docs/create_ios_project.html#add_url_scheme) 
- Get Amazon API key for your iOS app
 
 
## Installation

```
cordova plugin add https://github.com/edu-com/cordova-plugin-amazon-login.git#v2.0.0 --variable IOS_API_KEY="your-key-here"
```

## API

### Authorize

`window.AmazonLoginPlugin.authorize(Object options, Function success, Function failure)`

Success function returns an Object like:

	{
		accessToken: "...",
		user: {
		    name: "Full Name",
            email: "email@example.com",
            user_id: "634565435",
            postal_code: '12345'

		}
	}

Failure function returns an error String.


### FetchUserProfile

TBD

### GetToken

`window.AmazonLoginPlugin.getToken(Object options,Function success, Function failure)`

Success function returns an Object like:

	{
		accessToken: "...",
		user: {
		    name: "Full Name",
            email: "email@example.com",
            user_id: "634565435",
            postal_code: '12345'

		}
	}

Failure function returns an error String.


### SignOut

`window.AmazonLoginPlugin.signOut(Function success, Function failure)`
