/* Deselect all the parent tabs and hide all the content, then select the specified tab */
function select_fk_tab(tab_selector, content_selector, index, num_tabs)
{
    for (var i=0; i<num_tabs; i++)
    {
        $(tab_selector + i.toString()).removeClass('current');
        $(content_selector + i.toString()).hide();
    }
    $(tab_selector + index.toString()).addClass('current');
    $(content_selector + index.toString()).show();
}

