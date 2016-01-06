
# cordova-plugin-CDVNavBar

This plugin adds NavigationBar to your Cordova Applications.

#NOTE
You should also install CDVTabBar plugin to work properly.


## Installation

    cordova plugin add cordova-plugin-cdvnavbar


### Supported Platforms

- iOS

### Example

```javascript
navbar.create();
navbar.hideLeftButton()
navbar.hideRightButton();
navbar.setupRightButton("", 'barButton:Refresh', null);
navbar.showRightButton();
navbar.settitle("Tab 1");
navbar.show();
```
