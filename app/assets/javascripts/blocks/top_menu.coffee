$(document).on 'page:load', ->
  # desktop menu
  $triggers = $('.l-top_menu .submenu').parent()
  $triggers.each ->
    $trigger = $(@)
    $menu = $trigger.children('.submenu').show()
    height = $menu.height()
    borderBottomWidth = parseInt $menu.css('borderBottomWidth')
    $menu.css
      height: 0
      borderBottomWidth: 0

    $trigger.hoverDelayed ->
      $menu.css
        height: height
        borderBottomWidth: borderBottomWidth
    , ->
      $menu.css
        height: 0
        borderBottomWidth: 0

    , 0, $menu.data('duration') || 150

  # mobile menu
  $('.mobile-menu-toggler').click ->
    if !@classList.contains('active') && $('.mobile-search-toggler').hasClass('active')
      $('.mobile-search-toggler').click()

    @classList.toggle 'active'

    $('.l-top_menu .menu-items')
      .toggleClass('active')
      .siblings()
      .removeClass 'active'

  $('.mobile-search-toggler').click ->
    if !@classList.contains('active') && $('.mobile-menu-toggler').hasClass('active')
      $('.mobile-menu-toggler').click()

    @classList.toggle 'active'

    $('.l-top_menu .menu-search')
      .toggleClass('active')
      .siblings()
      .removeClass 'active'

    $('.b-main_search input').focus()

  #$('.mobile-sign-in-toggler').click ->
    #$('.usernav').trigger 'click'

  $('.submenu-activator').on 'click', ->
    $(@).prev().click()

  $('.submenu-toggler').on 'click', ->
    $(@).toggleClass 'active'
    $(@).siblings('.submenu').toggleClass 'active'
