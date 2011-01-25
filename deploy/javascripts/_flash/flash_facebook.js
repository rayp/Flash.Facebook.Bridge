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
    var _on_init = function(response) {
        log("FBAS: _on_init");
        $f.ei.on_fb_ready(response);
    };
    var _on_login_ok = function(response) {
        log("FBAS: _on_login_ok");
        $f.ei.on_fb_logged_in(response);
    };
    var _on_login_cancel = function(response) {
        log("FBAS: _on_login_cancel");
        $f.ei.on_fb_login_cancel(response);
    };
    var _on_logout = function(response) {
        log("FBAS: _on_logout");
        $f.ei.on_fb_logged_out(response);
    };
    var _on_login_change = function(response) {
        log("FBAS: _on_login_change");
        $f.ei.on_fb_login_change(response);
    };
    var _on_event = function(event, response) {
        log("FBAS: _on_event: " + event);
        $f.ei.on_fb_event(event, response);
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
    that.subscribe = function(event) {
        log("FBAS: subscribe: event: " + event);
        $fb.subscribe(event, _on_event);
    };
    that.unsubscribe = function(event) {
        log("FBAS: unsubscribe: event: " + event);
        $fb.unsubscribe(event, _on_event);
    };
    that.ui = function(data) {
        log("FBAS: ui: event: " + data.method);
        $fb.ui(data, _on_event);
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