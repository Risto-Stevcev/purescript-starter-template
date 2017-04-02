'use strict';

exports._captureState = function(foreign) {
  window.appState = foreign;
  return {};
}

exports.setWindowProperty = function(property) {
  return function(object) {
    return function() {
      window[property] = object;
    }
  }
}
