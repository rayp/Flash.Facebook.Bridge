(function() {
    // Set params
    $fb.login_permissions = "publish_stream";
	$f.alternate_html = '<a href"http://get.adobe.com/flashplayer/">' +
						'<img' +
						' alt="Get Adobe Flash Player"' +
						' src="http://www.adobe.com/images/shared/download_buttons/get_adobe_flash_player.png"' +
						'>' +
						'</a>';
	
	// Working to remove this Adobe code
	FBAS.setSWFObjectID($f.id);
    
	// Init Flash & Bridge
	$fbas.init();
    $f.init();
} ());