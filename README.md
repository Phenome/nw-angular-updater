# nw-angular-updater
Node Webkit Angular Updater Service

### How it works
* `infoUrl` must point to a json file which has a `version` property with an integer value.
* `downloadUrl` must point to the Node Webkit packaged app  
** https://github.com/nwjs/nw.js/wiki/How-to-package-and-distribute-your-apps
* `filename` is the file name to be overwritten when the download completes. It must exist _(or there wouldn't be nothing to update, would it?)_
* `currentVersion` Sets the current app version, to match against the one from `infoUrl`
* `auto` (optional; Defaults to true) Automatically downloads new package (if needed) upon app execution. Otherwise, it just checks if an update is needed.
 

1. Upon app execution, it queries `infoUrl` and parses its json for the property `version`
2. If `version` is greater than `currentVersion`, it starts downloading from `downloadUrl`
3. When the download completes, it renames the downloaded file to `filename`

### How to use:
Install through bower
```
bower i --save nw-angular-updater
```
Then add `'nwUpdater'` as a dependency
```
app = angular.module('yourApp', ['nwUpdater'])
```
Now you **need** to configure the provider with the required values
```
app.config(function(nwUpdateProvider) {
  nwUpdateProvider
  .setInfoUrl('http://url.to/latest.info')
  .setDownloadUrl('http://url.to/latest.nw')
  .setFilename('yourapp.nw')
  .setCurrentVersion 1
})
```
Then you just inject it into a controller
```
app.controller('yourController', ['nwUpdate', function(nwUpdate) {
});
```
And you're set. 

### Properties and Methods
nwUpdate has these `Boolean` properties:
* `checking` - When the service is querying `infoUrl` for information.
* `updateRequired` - When the service
* `downloading` - When the service is downloading the new package from `downloadUrl`
* `restartRequired` - Package downloaded and ready. Restart app to load new package.

nwUpdate has these methods:
* `check()` - Checks if an update is needed
* `checkAndUpdate()` - Checks if an update is needed and downloads the new package in one command.
