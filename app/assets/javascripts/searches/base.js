$(function() {
  
  $("#low").tokens();
  $("#basic").tokens();
  $("#high").tokens();
  
  $(".token-input").keypress(function(e) {
    if (e.which == 13){
      var tokenValue = $(this).val();
      if (tokenValue.length <= 2){
        return false;
      }
      var tokens = allTokens();
      var priority = $(this).data('priority');
      if (tokens.indexOf(tokenValue) == -1){
        $("#"+priority).tokens("add", [{label:tokenValue, value: tokenValue}]);         
      }else{
        downUp('#duplicate-alert');
      }
      $(this).val('');
      $(this).focus();
      return false;
    }
  });
  
  $('#search-button').click(function() {
    $('.token-input').trigger({ type: 'keypress', which: '13' });
    var low = $('#low').tokens('values');
    var basic = $('#basic').tokens('values');
    var high = $('#high').tokens('values');
    if (basic.length == 0 && high.length == 0){
      downUp('#invalid-tokens');
    }else{
      $.post('/searches', {
        'low[]': low,
        'basic[]': basic,
        'high[]': high
      })
    }
  });
  
  $('#clear-button').click(clearTokens);
  
  $(document).endlessScroll({
  	fireOnce: true,
  	fireDelay: 1500,
  	ceaseFire: function(){
  		return $('#infinite-scroll').length ? false : true;
  	},
  	bottomPixels:300,
    callback: function(fireSequence){
      $.ajax({
  	    url: $(this).data('url'),
  	    data: {
  			  page: fireSequence + 1,
  		  },
  		  dataType: 'script',
  	  });
    }
  });
});