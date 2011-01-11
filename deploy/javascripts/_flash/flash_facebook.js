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
            extendedPermissions = (extendedPermissions == null) ? '' : extendedPermissions;
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