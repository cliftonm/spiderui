function select_tab(tab, tab_content) {
    $("li[id='tab_tab0']").removeClass('current')
    $("li[id='tab_tab1']").removeClass('current')
    $("li[id='tab_tab2']").removeClass('current')
    $("div[id='tab_content0']").hide()
    $("div[id='tab_content1']").hide()
    $("div[id='tab_content2']").hide()
    $("li[id='" + tab + "']").addClass('current')
    $("div[id='" + tab_content + "']").show()
}
