function downUp (selector) {
  $(selector).slideDown('slow', function() {
    setTimeout(function() {
      $(selector).slideUp('slow');
    }, 3 * 1000);
  });
}

function allTokens() {
  return $("#low").tokens("values").concat($("#basic").tokens("values").concat($("#high").tokens("values")));
}

function clearTokens(){
  $('#low').tokens('remove', allTokens());
  $('#basic').tokens('remove', allTokens());
  $('#high').tokens('remove', allTokens());
}