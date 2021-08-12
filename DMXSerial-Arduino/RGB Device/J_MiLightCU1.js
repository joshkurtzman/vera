var SET_HUE_SID = "urn:dcineco-com:serviceId:MiLightCU1";
var hueField = { width: 600, height: 50 };
var miLightCUDevice;

/////////////
// Color tab - Created for Hue plugin by @nlrb, Modified for MiLightCU1 plugin by @RexBeckett.
/////////////

function miLightCUColorTab(deviceID) {
   miLightCUDevice = deviceID;
   var html = '<style type="text/css">canvas { cursor: crosshair }</style>';
   html += '<canvas id="miLightCUCanvas" width="' + hueField.width + '" height="' + hueField.height + '" style="border:0px;" ';
   html += 'onmousemove="miLightCUMouseMove(event)" onmouseout="miLightCUMouseOut()" onclick="miLightCUMouseClick(event)">';
   html += 'Your browser does not support the HTML5 canvas tag.</canvas>';
   html += '<div id="miLightCUCursor" style="position: absolute; top: ' + (hueField.height + 25) + '; left: 50"></div>';
   set_panel_html(html);
   miLightCUCreateColorField("miLightCUCanvas");
}

function miLightCUCreateColorField(id) {
   var c = document.getElementById(id);
   var dc = c.getContext("2d");

   for (var i = 0; i < hueField.width; ++i) {
   var ratio = 1 - (i / hueField.width);
   var hue = Math.floor(((360 * ratio) + 254) % 360);
   var sat = 100;
   var lum = 50;
   var grad = dc.createLinearGradient(0, 0, 0, hueField.height);
   grad.addColorStop(0, 'hsl(' + hue + ',' + sat + '%,' + lum + '%)');
   grad.addColorStop(1, 'hsl(' + hue + ',' + sat + '%,' + lum + '%)');
   dc.fillStyle = grad;
   dc.fillRect(i, 0, i + 1, hueField.height);
   }
}

function miLightCUGetHue(event) {
   function getOffset(el) {
      var _x = 0;
      var _y = 0;
      while (el && !isNaN(el.offsetLeft) && !isNaN(el.offsetTop)) {
         _x += el.offsetLeft;
         _y += el.offsetTop;
         el = el.offsetParent;
      }
      return { top: _y, left: _x };
   }
   var elem = document.getElementById("miLightCUCanvas");
   var x = 0;
   var y = 0;
   if (elem !== undefined) {
      x = event.clientX - getOffset(elem).left - 1;
      y = event.clientY - getOffset(elem).top - 2;
      if (x < 0) { x = 0 };
      if (y < 0) { y = 0 };
   }
   var hue = -1;
      // Color field
      hue = Math.floor(255 * x / (hueField.width - 1)) % 256;
   return { 'hue': hue };
}

function miLightCUMouseMove(event) {
   var val = miLightCUGetHue(event);
   var elem = document.getElementById("miLightCUCursor");
       elem.innerHTML = "Hue: " + val.hue;
}

function miLightCUMouseOut() {
   document.getElementById("miLightCUCursor").innerHTML = '';
}

function miLightCUMouseClick(event) {
   var val = miLightCUGetHue(event);
      miLightCUCallAction(val.hue);
}

function miLightCUCallAction(newhue) {
   var result = '';
   var q = {
      'id': 'lu_action',
      'output_format': 'xml',
      'DeviceNum': miLightCUDevice,
      'serviceId': SET_HUE_SID,
      'action': 'SetHue',
	  'newHue': newhue,
	  'timestamp': new Date().getTime()   //we need this to avoid IE caching of the AJAX get
   };
   new Ajax.Request (command_url+'/data_request', {
      method: 'get',
      parameters: q,
      onSuccess: function (response) {
      },
      onFailure: function (response) {
      },
      onComplete: function (response) {
         result = response.responseText;
      }
   });
   return result;
}