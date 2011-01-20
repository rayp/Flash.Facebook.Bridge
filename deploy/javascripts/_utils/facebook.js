/*
 * FACEBOOK Helper
 *
 * @author: AKQA
 * @version: 0.2
 * @date: May 22, 2010
 * @requires: browser.js (Browser detection scripts)
 *
 */

/*
 * HOW TO USE
 *
 *
	// Configure the FB helper
		$fb.app_id = "125414080817457";

	// Load the SDK and initialize
		$fb.init();

	// Listen for events
		$fb.on_init = function(args){ ... };
		$fb.on_login_ok = function(args){ ... };
		$fb.on_get_user = function(args){ ... };

	// Get Login Status
		$fb.get_login_status();
	// Force login dialog
		$fb.login();
	// Share a link
		$fb.share(url);

	// Customize the Login XFBML overlay (will appear on Chrome and other popup blocking browsers)
		$fb.login_dialog_body= "<p>If you want to get custom content authorize.</p>";
		$fb.login_dialog_button= "Connect with Facebook";
		$fb.login_dialog_witdh= 300;
		$fb.login_dialog_height= 200;
*
*
*/

var $fb = function() {

    // output to console
    var log = function(ob) {
        if (!that.debug) return;
        try {
            console.log(ob);
        } catch(e) {
            // alert(ob);
            }
    };

    // FACEBOOK ASYNC. setup
    window.fbAsyncInit = function() {
        log('FB: fbAsyncInit: ' + that.app_id);
        FB.init({
            appId: that.app_id,
            status: true,
            cookie: true,
            xfbml: true
        },
        that.xd_receiver);

        _on_init();
    };

    var that = {
        debug: false,
        app_id: '',
        session: {},
        xd_receiver: 'xd_receiver.htm',
        login_permissions: "publish_stream, offline_access, create_event, rsvp_event, sms",
        canvas_width: 760,
        canvas_height: 1800,
        // listeners
        on_init: function(response) {},
        on_login: function(response) {},
        on_logout: function(response) {},
        on_login_ok: function(response) {},
        on_login_cancel: function(response) {},
        on_status_change_authorized: function() {},
        on_status_change_unauthorized: function() {},
        on_session_change_authorized: function() {},
        on_session_change_unauthorized: function() {},
        on_dialog_close: function() {}
    };

    that.init = function() {
        var protocol = document.location.protocol;
        protocol = (protocol.indexOf("file") < 0) ? protocol: "http:";
        var e = document.createElement('script');
        e.async = true;
        e.src = protocol + '//connect.facebook.net/en_US/all.js';
        document.getElementById('fb-root').appendChild(e);
    };

    that.set_canvas_size = function(w, h) {
        FB.Canvas.setSize({
            width: w || that.canvas_width,
            height: h || that.canvas_height
        });
    };

    that.get_login_status = function() {
        log("FB: get_login_status")
        FB.getLoginStatus(function(response) {
            if (response.session) {
                // logged in and connected user, someone you know
                var i;
                for (i in response.session) {
                    that.session[i] = response.session[i];
                }

                _on_status_change_authorized();
            } else {
                // no user session available, someone you don't know
                _on_status_change_unauthorized();
            }
        });
    };

    that.login = function() {
        log("FB: login: " + that.login_permissions);
        FB.login(_on_login, {
            perms: that.login_permissions
        });
    };

    that.logout = function() {
        log("FB: logout");
        FB.logout(_on_logout);
    };

    that.get_session = function() {
        log("FB: get_session");
        return that.session.access_token ? that.session: (that.session = _get_session_from_cookie());
        // if we didn't get the session, we need it somehow for IE
    };

    that.get_access_token = function() {
        log("FB: get_access_token");
        return that.session.access_token ? that.session.access_token: _get_access_token_from_cookie();
        // if we didn't get the access on the session, we need it somehow for IE
    };

    that.subscribe = function(event, handler) {
        log("FB: subscribe: event: " + event);
        FB.Event.subscribe(event, _on_event(event, handler));
    };

    that.unsubscribe = function(event, handler) {
        log("FB: unsubscribe: event: " + event);
        FB.Event.unsubscribe(event, _on_event(event, handler));
    };

    // Private Methods
    var _init_listeners = function() {
        FB.Event.subscribe('auth.sessionChange',
        function(response) {
            if (response.session) {
                // A user has logged in, and a new cookie has been saved
                _on_session_change_authorized();
            } else {
                // The user has logged out, and the cookie has been cleared
                _on_session_change_unauthorized();
            }
        });
        FB.Event.subscribe('auth.statusChange',
        function(response) {
            if (response.session) {
                // A user has logged in, and a new cookie has been saved
                _on_session_change_authorized();
            } else {
                // The user has logged out, and the cookie has been cleared
                _on_session_change_unauthorized();
            }
        });
        FB.Event.subscribe('auth.login',
        function(response) {
            // do something with response
            log("FB: Event - auth.login - The user has logged in");
        });
        FB.Event.subscribe('auth.logout',
        function(response) {
            // do something with response
            log("FB: Event - auth.logout - The user has logged out");
        });
    };

    var _on_init = function() {
        log("FB: _on_init");
        _get_session_from_cookie();
        _init_listeners();
        that.set_canvas_size();
        that.get_login_status();
        that.on_init();
    };

    var _on_login = function(response) {
        log("FB: _on_login");
        that.on_login(response);
        if (response.session) {
            that.on_login_ok(response);
        } else {
            that.on_login_cancel(response);
        }
    };

    var _on_logout = function(response) {
        log("FB: _on_logout");
        that.on_logout(response);
    };

    var _on_event = function(event, handler) {
        log("FB: _on_event");
        return function(response) {
            log("FB: _on_event: response: " + response);
            handler(event, response);
        };
    };

    var _on_status_change_authorized = function() {
        log("FB: _on_status_change_authorized - Logged in and connected user, someone you know")
        that.on_status_change_authorized();
    };

    var _on_status_change_unauthorized = function() {
        log("FB: _on_status_change_unauthorized - No user session available, someone you dont know")
        that.on_status_change_unauthorized();
    };

    var _on_session_change_authorized = function() {
        log("FB:  Event - _on_session_change_authorized - A user has logged in, and a new cookie has been saved");
        that.on_session_change_authorized();
    };

    var _on_session_change_unauthorized = function() {
        log("FB:  Event - _on_session_change_unauthorized - The user has logged out, and the cookie has been cleared");
        that.on_session_change_unauthorized();
    };

    var _get_session_from_cookie = function() {
        log("FB: _get_session_from_cookie");
        // The cookie set by FB on the canvas iFrame looks something like this:
        // access_token = 107783515931011 % 7C2.DxkvtKur_HF0JasR27X_1g__.3600.1294797600 - 759555051 % 7CAHAIhiypxRky2L3fuPtg2eE4uYE
        // & expires = 1294797600
        // & secret = JmoHNKpaa9fhCpE6EPpXqw__
        // & session_key = 2.DxkvtKur_HF0JasR27X_1g__.3600.1294797600 - 759555051
        // & sig = 4dacf8b3bbdbe28b3f229226c7604a2e
        // & uid = 759555051
        that.session = {};
        var str = document.cookie;
        str = str.substring(str.indexOf("\"") + 1, str.lastIndexOf("\""));
        if (str === null || str.length === 0) {
            return that.session;
        }
        var pairs = str.split("&");
        if (pairs.length === 0) {
            return that.session;
        }
        var arr;
        var pair;
        for each(pair in pairs) {
            arr = pair.split("=");
            that.session[arr[0]] = arr[1];
        }

        return that.session;
    };

    var _get_access_token_from_cookie = function() {
        // The cookie set by FB on the canvas iFrame looks something like this:
        // fbs_123966030957513="access_token=123966030957513|2.wUmpcEVNczcJN5gLUkb0fw__.3600.1282363200-100001080361610|mzaFDWj3kqlGJu1HtqkMwiqMfa4.&expires=128	
        var str = document.cookie;
        var l = str.split("access_token=");
        if (l.length <= 0) {
            return null;
        }
        str = l[1];
        l = str.split("&");
        if (l.length <= 0) {
            return null;
        }
        return l[0];
    };

    var _on_dialog_close = function(response) {
        log("FB: _on_dialog_close");
        that.on_dialog_close(response);
    };

    return that;
} ();
