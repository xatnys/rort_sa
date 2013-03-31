$(document).on('keyup', '#micropost_content', function(){ 
	var thres = 140-$(this).val().length;
	if (thres <= 0 ) { 
		$('#chars').addClass("maxlimit"); 
	} else {
		$('#chars').removeClass("maxlimit");
	}
	if (thres == 140) {
		$('#chars').text("");
	} else {
		$('#chars').text(thres + " characters remaining.");
	}
});