
# cordova-plugin-CDVNavBar

This plugin adds NavigationBar to your Cordova Applications.

## Installation

    cordova plugin add cordova-plugin-cdvnavbar


### Supported Platforms

- iOS

### Example For NavigationBar

```javascript
navbar.create();
navbar.hideLeftButton()
navbar.hideRightButton();
navbar.setupRightButton("", 'barButton:Refresh', null);
navbar.showRightButton();
navbar.settitle("Tab 1");
navbar.show();
```

### Image instead of title
```javascript
navbar.setLogo(‘IMAGE’);

// Image can be a URL to an image starting with http:// or https://
// Or can be the title of the image added to the xcode project
```

### Example Adding Drawer to NavigationBar
```javascript
var draweritems = [];
draweritems.push(["Page1","index.html","icon.png", "im the badge"]);
draweritems.push(["Page2","index2.html","", "no badge"]);
draweritems.push(["Page3","index3.html","", null]);
navbar.setupDrawer(draweritems, "#ffffff");
```
