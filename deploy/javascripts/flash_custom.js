/*
 *
 * Flash<->Facebook Integration file
 * @author: omar.rodriguez
 * @version: 0.3
 * @date: June 4, 2010
 * @requires: flash.js, facebook.js
 *
 */

/** ***************************** */

$fb.login_permissions = "publish_stream";

/* We'll initialize FACEBOOK when FLASH is ready */
$f.on_ready = function() {
	$f.log("FLASH: on_ready");
	
	$fb.init();
};

$f.init();

/** ***************************** */

/* FB >> JS (Listeners) */
/* Listen for events from Facebook */
$fb.on_login_ok = on_login_ok;
$fb.on_login_cancel = on_login_cancel;
$fb.on_logout = on_logout;
$fb.on_login_change_authorized = on_login_change;
$fb.on_login_change_unauthorized = on_login_change;

/* AS >> JS */
/* Prepare function to be called from the Flash */
function fb_get_login_status() {
	$fb.get_login_status();
};
function fb_login() {
	$fb.login();
};
function fb_logout() {
	$fb.logout();
};

/* JS >> AS */
/* Prepare functions that will be called inside the Flash */
function on_login_ok(args) {
	$f.log("FBFL: on_login_ok");
	$f.ei.on_logged_in(args);
};
function on_login_cancel(args) {
	$f.log("FBFL: on_login_cancel");
	$f.ei.on_login_cancel(args);
};
function on_logout(args) {
	$f.log("FBFL: on_logout");
	$f.ei.on_logged_out(args);
};
function on_login_change(args) {
	$f.log("FBFL: on_login_change");
	$f.ei.on_login_change(args);
};