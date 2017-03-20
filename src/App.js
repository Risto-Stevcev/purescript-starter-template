'use strict';

exports._captureState = function(foreign) {
  window.appState = foreign;
  return {};
}
