/*
 * FLASH Helper
 *
 * @author: AKQA
 * @version: 0.2
 * @date: May 22, 2010
 * @requires: swfobject.js
 *
 */

/*
 *
 * HOW TO USE
 *
 *
 // Configure the flash
 $f.file_name = "Btn.swf";

 // Set listeners
 $f.on_init = function(){ ... }; // The SWF loaded
 $f.on_ready = function(){ ... }; // The ExternalInterface is ready through $f.ei

 // Embed the SWF with swbobject (after getting ready)
 $f.init();
 *
 *
 * Notes:
 * 		on_ready:
 *		will be fired when ExternalInterface calls the method.
 * 		To assist with this use the AS class com.akqa.utisl.JSBridge.as
 */

var $f = function() {

	var strHref = window.location.href;

	if (strHref.indexOf("?") > -1) {
		var strQueryString = strHref.substr(strHref.indexOf("?") + 1);
		var aQueryString = strQueryString.split("&");
		for ( var iParam = 0; iParam < aQueryString.length; iParam++) {
			var aParam = aQueryString[iParam].split("=");
			$f.flashvars[aParam[0]] = aParam[1];
		}
	}

	return {
		/* Embed options */
		id : 'flashContent',
		/* Id of the div to substitute: <div id="flashContent"></div> */
		width : "800",
		height : "580",
		player_version : "9.0.0",
		base_path : location.href.substring(0, location.href.lastIndexOf("/") + 1),
		file_name : "main.swf",
		/* use 'false' if none */
		express_install : false,
		/* prevents the swf from being cached */
		use_cache_breaker : false,
		app_version : 0000,
		/* DOM node of the Flash object */
		dom : null,
		/* ExternaInterface access inside the SWF (DOM node alias) */
		ei : null,
		/* FlashVars */
		flashvars : {
			JSBridge_Callback : "$f._on_ready"
		},
		/* FlashVars */
		params : {
			menu : "false",
			quality : "high",
			scale : "noscale",
			salign : "tl",
			wmode : "opaque",
			bgcolor : "#ffffff",
			allowFullScreen : "true",
			allowScriptAccess : "always"
		},
		attributes : {},
		/* The SWF is loaded */
		_on_init : function() {
			$f.log("_on_init");
			$f.on_init();
		},
		/* The SWF is ready to be accessed */
		_on_ready : function() {
			$f.log("FLASH: _on_ready");
			$f.dom = document.getElementById($f.id);
			$f.ei = document.getElementById($f.id);
			$f.on_ready();
		},
		/* SWFObject embed (internal) */
		alternate_html : 'This site requires the latest Flash Player',
		embed : {
			init : function() {
				if (swfobject.hasFlashPlayerVersion($f.player_version)) {
					$f.embed.add();
				} else {
					// prompt to upgrade to flash || serve HTML
					document.getElementById($f.id).innerHTML = $f.alternate_html;
				}
			},
			add : function() {
				var swfFile = $f.base_path + $f.file_name;
				swfFile += $f.use_cache_breaker ? "?cachebreaker="
						+ Math.random() : "";

				var expressInstallFile = $f.express_install ? $f.base_path
						+ $f.express_install : false;

				swfobject.embedSWF(swfFile, $f.id, $f.width, $f.height,
						$f.player_version, expressInstallFile, $f.flashvars,
						$f.params, $f.attributes);

				$f._on_init();
			}
		},

		/* Log */
		log : function(ob) {
			try {
				console.log(ob);
			} catch (e) {
				// alert(ob);
			}
		},

		/* Initialization */
		init : function() {
			$f.log("FLASH: init...");
			$f.embed.init();
		},

		/* Listeners */

		// The SWF is loaded
		on_init : function() {
			$f.log("FLASH: on_init: The SWF is loaded");
		},
		// The External interface is ready
		on_ready : function() {
			$f
					.log("FLASH: on_ready: The External interface is ready & the SWF ready to be accessed");
		}

	}
}();
