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

    var log = function(ob) {
		if (!that.debug) return;
        try {
            console.log(ob);
        } catch(e) {
            // alert(ob);
            }
    };

    var _detect = function() {
        if (swfobject.hasFlashPlayerVersion(that.player_version)) {
            _embed();
        } else {
            // prompt to upgrade to flash || serve HTML
            document.getElementById(that.id).innerHTML = that.alternate_html;
        }
    };

    var _embed = function() {
        var swfFile = that.base_path + that.file_name;
        swfFile += '?v=' + that.app_version;
        swfFile += that.use_cache_breaker ? "&cb=" + (Math.random() * 1000000).toString().split('.')[0] : "";

        swfobject.embedSWF(
        swfFile
        , that.id
        , that.width
        , that.height
        , that.player_version
        , that.express_install ? that.base_path + that.express_install: false
        , that.flashvars
        , that.params
        , that.attributes
        , _on_embed
        );
    };

    // The SWF is embedded... or not
    var _on_embed = function(e) {
        log("FLASH: _on_embed : " + e.success);
        if (e.success) {
            _on_init();
        } else {
            log("ERROR: The Flash Movie " + e.id + " was not embedded.")
        }
    };

    // The SWF is loaded
    var _on_init = function() {
        log("FLASH: _on_init");
        that.on_init();
    };

    // The SWF is ready to be accessed
	// Not sure this is the best callback solution but it keeps this method protected
    var _on_ready = '' +
    'function() {' +
    '$f.log("FLASH: _on_ready");' +
    '$f.dom = document.getElementById($f.id);' +
    '$f.ei = document.getElementById($f.id);' +
    '$f.on_ready();' +
    '}';

    var that = {
		debug: false,
		log: log,
        // Id of the div to substitute: <div id="flashContent"></div>
        id: 'flashContent',
        width: "800",
        height: "580",
        player_version: "9.0.0",
        base_path: location.href.substring(0, location.href.lastIndexOf("/") + 1),
        file_name: "main.swf",
        // use 'false' if none
        express_install: false,
        // prevents the swf from being cached
        use_cache_breaker: false,
        // application version (add to URL requests to force newest files from CDN)
        app_version: 0000,
        // DOM node of the Flash object
        dom: null,
        // ExternaInterface access inside the SWF (DOM node alias)
        ei: null,
        flashvars: {
            JSBridge_Callback: _on_ready,
			JSBridge_DebugKey: null
        },
        params: {
            menu: "false",
            quality: "high",
            scale: "noscale",
            salign: "tl",
            wmode: "opaque",
            bgcolor: "#ffffff",
            allowFullScreen: "true",
            allowScriptAccess: "always"
        },
        attributes: {},
        alternate_html: 'This site requires the latest Flash Player',
        // Listeners
        on_init: function() {log('FLASH: on_init')},
        on_ready: function() {log('FLASH: on_ready')}
    };

    that.init = function() {
        log("FLASH: init");
        // Add query string params for FlashVars
        var strHref = window.location.href;
        if (strHref.indexOf("?") > -1) {
            var strQueryString = strHref.substr(strHref.indexOf("?") + 1);
            var aQueryString = strQueryString.split("&");
            for (var iParam = 0; iParam < aQueryString.length; iParam++) {
                var aParam = aQueryString[iParam].split("=");
                that.flashvars[aParam[0]] = aParam[1];
            }
        }

        _detect();
    };

    return that;
} ();
