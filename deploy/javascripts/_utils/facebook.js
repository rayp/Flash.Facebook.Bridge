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
        try {
            console.log(ob);
        } catch(e) {
            // alert(ob);
		}
    };

	// FACEBOOK ASYNC. setup
    window.fbAsyncInit = function() {
        log('init app:' + that.app_id);
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
        app_id: '',
        session: {},
        xd_receiver: 'xd_receiver.htm',
        login_permissions: "publish_stream, offline_access, create_event, rsvp_event, sms",
        canvas_width: 760,
        canvas_height: 1800,
        // should be set based on user agent
        supports_popups: true,
        // login params for older browser which do not support popups
        login_dialog: {
            body: "",
            button: "Connect with Facebook",
            width: null,
            height: null
        },
        fmbl_dialog: null,
        // listeners
        on_init: function(response) {},
        on_login: function(response) {},
        on_logout: function(response) {},
        on_login_ok: function(response) {},
        on_login_cancel: function(response) {},
        on_login_status_authorized: function() {},
        on_login_status_unauthorized: function() {},
        on_login_change_authorized: function() {},
        on_login_change_unauthorized: function() {},
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

                _on_login_status_authorized();
            } else {
                // no user session available, someone you don't know
                _on_login_status_unauthorized();
            }
        });
    };

    that.login = function() {
        log("FB: login: " + that.login_permissions);

        if (that.supports_popups) {
            FB.login(_on_login, {
                perms: that.login_permissions
            });
        }
        else {
            _show_login_dialog();
        }
    };

    that.logout = function() {
        log("FB: logout");
        FB.logout(_on_logout);
    };

    that.get_access_token = function() {
        return that.session.access_token ? that.session.access_token: _get_access_token_from_cookie();
        // if we didn't get the access on the session, we need it somehow for IE
    };

    // Private Methods
    var _init_listeners = function() {
        FB.Event.subscribe('auth.sessionChange',
        function(response) {
            if (response.session) {
                // A user has logged in, and a new cookie has been saved
                _on_login_change_authorized();
            } else {
                // The user has logged out, and the cookie has been cleared
                _on_login_change_unauthorized();
            }
        });
        FB.Event.subscribe('auth.login',
        function(response) {
            // do something with response
            log("FB: Event - auth.login - The user has logged in");
            //$fb.get_user();
        });
    };

    var _create_login_dialog = function() {
        fbml = ''
        + '<div style="font-size:50%; clear:both;">'
        + that.login_dialog.body
        + '</div>'
        + '<div style="text-align: center; clear:both;">'
        + '<fb:login-button v="2" size="large" perms="'
        + that.login_permissions
        + '">'
        + that.login_dialog.button
        + '</fb:login-button>'
        + '</div>';

        _create_fbml_dialog(fbml, that.login_dialog.width, that.login_dialog.height);
    };

    var _create_fbml_dialog = function(fbml, width, height) {
        fbml = "" || fbml;
        width = 0 || width;
        height = 0 || height;

        if (!that.fmbl_dialog)
        that.fmbl_dialog =
        FB.Dialog._findRoot(
        FB.Dialog.create({
            content: (
            '<div class="fb_dialog_loader">'
            // +'<a id="fb_dialog_loader_close"></a><br/>'
            + '<a id="fb_dialog_loader_close" style="float:right;"></a>'
            + '<div style="width:' + width + 'px;height:' + height + 'px; clear:both;">'
            + FB.Intl._tx(fbml)
            + '</div>'
            + '</div>')
        }));

        var close_btn = FB.$('fb_dialog_loader_close');
        FB.Dom.addCss(close_btn, 'fb_dialog_top_right');
        close_btn.onclick = _hide_fbml_dialog;
    };

    var _show_login_dialog = function() {
        //$fb.show_fbml_dialog();
        };

    var _hide_login_dialog = function() {
        //$fb.hide_fbml_dialog();
        };

    var _on_init = function() {
        log("FB: _on_init")
        that.set_canvas_size();
        // create the login Dialog (so the inner XFBML is rendered before needed)
        if (!that.supports_popups) {
            _create_login_dialog();
        }
        // setup listeners
        _init_listeners();
        // check the login status
        that.get_login_status();
        // listener (user overriden)
        that.on_init();
    };

    var _on_login = function(response) {
        log("FB: _on_login");
        _hide_login_dialog();
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

    var _on_login_status_authorized = function() {
        log("FB: _on_login_status_authorized - Logged in and connected user, someone you know")
        that.on_login_status_authorized();
        //$fb.get_user();
    };

    var _on_login_status_unauthorized = function() {
        log("FB: _on_login_status_unauthorized - No user session available, someone you dont know")
        that.on_login_status_unauthorized();
    };

    var _on_login_change_authorized = function() {
        log("FB:  Event - _on_login_change_authorized - A user has logged in, and a new cookie has been saved");
        _hide_login_dialog();
        that.on_login_change_authorized();
        //$fb.get_user();
    };

    var _on_login_change_unauthorized = function() {
        log("FB:  Event - _on_login_change_unauthorized - The user has logged out, and the cookie has been cleared");
        that.on_login_change_unauthorized();
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
