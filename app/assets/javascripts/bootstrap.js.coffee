$ ->
  $("a[rel=popover]").popover offset: 10
$ ->
  $("[rel=tooltip]").tooltip()
$ ->
  $(".topbar-wrapper").dropdown()
$ ->
  $(".alert").alert()
$ ->
  domModal = $(".modal").modal(
    backdrop: true
    closeOnEscape: true
  )
  $(".open-modal").click ->
    domModal.toggle()  
