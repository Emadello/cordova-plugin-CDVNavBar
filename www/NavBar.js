cordova.define("cordova-plugin-CDVTabBar.NavBar", function(require, exports, module) { /*
*
* Licensed to the Apache Software Foundation (ASF) under one
* or more contributor license agreements.  See the NOTICE file
* distributed with this work for additional information
* regarding copyright ownership.  The ASF licenses this file
* to you under the Apache License, Version 2.0 (the
* "License"); you may not use this file except in compliance
* with the License.  You may obtain a copy of the License at
*
*   http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing,
* software distributed under the License is distributed on an
* "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
* KIND, either express or implied.  See the License for the
* specific language governing permissions and limitations
* under the License.
*
*/

var exec = require('cordova/exec');
var platform = require('cordova/platform');

/**
* Provides access to notifications on the device.
*/
module.exports = {
    /**
    * Create a navigation bar.
    *
    * @param style: One of "BlackTransparent", "BlackOpaque", "Black" or "Default". The latter will be used if no style is given.
    */
    create: function(style, options) {
        options = options || {};
        if(!("style" in options))
        options.style = style || "Default";
        exec(null, null, "NavBar", "create", [style, options]);

    },

    show: function(style, options) {
        options = options || {};
        if(!("style" in options))
        options.style = style || "Default";
        exec(null, null, "NavBar", "show", [style, options]);
    },



    hide: function() {
    exec(null, null, "NavBar", "hide", []);
    },

    settitle: function(title) {
        exec(null, null, "NavBar", "setTitle", [title]);
    },

    hideLeftButton: function(style, options) {
        exec(null, null, "NavBar", "hideLeftButton", [style, options]);
    },

    hideRightButton: function(style, options) {
        exec(null, null, "NavBar", "hideRightButton", [style, options]);
    },

    showLeftButton: function(style, options) {
        exec(null, null, "NavBar", "showLeftButton", [style, options]);
    },

    showRightButton: function(style, options) {
        exec(null, null, "NavBar", "showRightButton", [style, options]);
    },

    setupLeftButton: function(title, image, thefunction) {
        this.leftButtonCallback = thefunction;
        exec(null, null, "NavBar", "setupLeftButton", [title, image, thefunction]);
    },

    leftButtonTapped: function() {
        if(typeof(this.leftButtonCallback) === "function")
        this.leftButtonCallback()
    },

    setupRightButton: function(title, image, thefunction) {
        this.rightButtonCallback = thefunction;
        exec(null, null, "NavBar", "setupRightButton", [title, image, thefunction]);
    },

        rightButtonTapped: function() {
        if(typeof(this.rightButtonCallback) === "function")
        this.rightButtonCallback()
    }



}


});