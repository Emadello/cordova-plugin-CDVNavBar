
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
### Example Adding Drawer to NavigationBar
```javascript
var draweritems = [];
draweritems.push(["Page1","index.html","icon.png", "im the badge"]);
draweritems.push(["Page2","index2.html","", "no badge"]);
draweritems.push(["Page3","index3.html","", null]);
navbar.setupDrawer(draweritems, "#ffffff");
```
