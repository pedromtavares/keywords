$(function() {
  
  $("img.loading").ajaxStart(function(){
		$(this).removeClass('none');
	}).ajaxComplete(function(){
		$(this).addClass('none');
	});
	
	$('.disable').live('click', function() {
	  $(this).addClass('disabled');
	});
	
});