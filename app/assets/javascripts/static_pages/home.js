$(function() {
	$("#micropost_content").bind('keyup', function() {
		var thres = 140-$(this).val().length
		if ( thres == 140 ) {
			$('#chars').text("");
		} else {
			$('#chars').text(thres + " characters remaining.");
		}
		if ( thres <= 0 ) {
			$('#chars').addClass("maxlimit");
		} else {
			$('#chars').removeClass("maxlimit");
		}
		return false;
	})
})