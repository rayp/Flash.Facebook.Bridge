var $fbas = function() {

    var log = function(ob) {
        if (!that.debug) return;
        try {
            console.log(ob);
        } catch(e) {
            // alert(ob);
            }
    }

    // JS >> AS
    // Prepare functions that will be called inside the Flash
    var _on_init = function(args) {
        log("FBAS: _on_init");
        $f.ei.on_ready(args);
    };
    var _on_login_ok = function(args) {
        log("FBAS: _on_login_ok");
        $f.ei.on_logged_in(args);
    };
    var _on_login_cancel = function(args) {
        log("FBAS: _on_login_cancel");
        $f.ei.on_login_cancel(args);
    };
    var _on_logout = function(args) {
        log("FBAS: _on_logout");
        $f.ei.on_logged_out(args);
    };
    var _on_login_change = function(args) {
        log("FBAS: _on_login_change");
        $f.ei.on_login_change(args);
    };

    var that = {
        debug: false
    };

    that.init = function() {

        $f.on_ready = function() {
            // Initialize FACEBOOK when FLASH is ready
            log("FBAS: on_ready");
            $fb.init();
        };

        // FB >> JS
        // Listen for events from Facebook
        $fb.on_init = _on_init;
        $fb.on_login_ok = _on_login_ok;
        $fb.on_login_cancel = _on_login_cancel;
        $fb.on_logout = _on_logout;
        $fb.on_login_change_authorized = _on_login_change;
        $fb.on_login_change_unauthorized = _on_login_change;
    };

    // AS >> JS
    // Prepare function to be called from the Flash
    that.login = function() {
        if ($fb.session.access_token) {
            log("FBAS: fb_login : Session exists, skip login popup.");
			_on_login_ok();
        } else {
            log("FBAS: fb_login : Session does not exist, proceed with login popup.");
            $fb.login();
        }
    };
    that.logout = function() {
        log("FBAS: fb_logout");
        $fb.logout();
    };
    that.subscribe = function(event, handler) {
        log("FBAS: subscribe");
        $fb.subscribe(event,
        function(response) {
            $f.ei.handler(event, response);
        });
    };
    that.unsubscribe = function(event, handler) {
        log("FBAS: unsubscribe");
        $fb.unsubscribe(event,
        function(response) {
            $f.ei.handler(event, response);
        });
    };
    that.get_login_status = function() {
        log("FBAS: get_login_status");
        $fb.get_login_status();
    };
    that.get_session = function() {
        log("FBAS: get_session");
        return $fb.get_session();
    };
    that.get_access_token = function() {
        log("FBAS: get_access_token");
        return $fb.get_access_token();
    };

    return that;
} ();

FBAS = function() {
    return {

        setSWFObjectID: function(swfObjectID) {
            FBAS.swfObjectID = swfObjectID;
        },

        init: function(opts) {
            FB.init(FB.JSON.parse(opts));

            FB.Event.subscribe('auth.sessionChange',
            function(response) {
                FBAS.updateSwfSession(response.session);
            });
        },

        setCanvasAutoResize: function(autoSize, interval) {
            FB.Canvas.setAutoResize(autoSize, interval);
        },

        setCanvasSize: function(width, height) {
            FB.Canvas.setSize({
                width: width,
                height: height
            });
        },

        login: function(opts) {
            FB.login(FBAS.handleUserLogin, FB.JSON.parse(opts));
        },

        addEventListener: function(event) {
            FB.Event.subscribe(event,
            function(response) {
                FBAS.getSwf().handleJsEvent(event,
                FB.JSON.stringify(response));
            });
        },

        handleUserLogin: function(response) {
            if (response.session == null) {
                FBAS.updateSwfSession(null);
                return;
            }

            if (response.perms != null) {
                // user is logged in and granted some
                // permissions.
                // perms is a comma separated list of
                // granted permissions
                FBAS.updateSwfSession(response.session, response.perms);
            } else {
                FBAS.updateSwfSession(response.session);
            }
        },

        logout: function() {
            FB.logout(FBAS.handleUserLogout);
        },

        handleUserLogout: function(response) {
            swf = FBAS.getSwf();
            swf.logout();
        },

        ui: function(params) {
            obj = FB.JSON.parse(params);
            method = obj.method;
            cb = function(response) {
                FBAS.getSwf().uiResponse(FB.JSON.stringify(response), method);
            }
            FB.ui(obj, cb);
        },

        getSession: function() {
            session = FB.getSession();
            return FB.JSON.stringify(session);
        },

        getLoginStatus: function() {
            FB.getLoginStatus(function(response) {
                if (response.session) {
                    FBAS.updateSwfSession(response.session);
                } else {
                    FBAS.updateSwfSession(null);
                }
            });
        },

        getSwf: function getSwf() {
            return document.getElementById(FBAS.swfObjectID);
        },

        updateSwfSession: function(session, extendedPermissions) {
            swf = FBAS.getSwf();
            extendedPermissions = (extendedPermissions == null) ? '': extendedPermissions;
            if (session == null) {
                swf.sessionChange(null);
            } else {
                swf.sessionChange(FB.JSON.stringify(session), FB.JSON.stringify(extendedPermissions.split(',')));
            }
        },

        log: function(ob) {
            try {
                console.log(ob);
            } catch(e) {
                alert(ob);
            }
        }
    };
} ();