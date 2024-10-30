$(function(){
    if($('body.active_admin.admin_tax_holdback').length > 0) {
        //scope currencies
        var scope_content = $('.scopes-content');
        var selected_currency = scope_content.data('currency');
        var selected_year = scope_content.data('year');
        var div = $('<div class="table_tools"></div>');
        var ul = $('<ul class="scopes table_tools_segmented_control"></ul>');
        $.each(['CAD', 'USD', 'ALL'], function (index, value) {
            if (value == selected_currency) {
                var li = $('<li class="scope selected"></li>');
            } else {
                var li = $('<li class="scope"></li>');
            }
            var link = $('<a href="#" class="table_tools_button">' + value + '</a>');
            link.click(function(){
                var currency = $(this).text().trim();
                var year = $('#scope_year').val();
                var url = '/admin/tax_holdback?currency=' + currency + '&year=' + year;
                window.location.href = url;
            });
            li.append(link);
            ul.append(li);
        });
        div.append(ul);
        // scope years
        var years = $.parseJSON(scope_content.text().trim());
        var select = $('<select id="scope_year" style="height:auto;margin-left: 5px;"></select>');
        $.each(years, function (index, value) {
            if (value == selected_year) {
                var option = '<option value="' + value + '"selected="selected">' + value + '</option>';
            } else {
                var option = '<option value="' + value + '">' + value + '</option>';
            }
            select.append(option);
        });
        select.change(function () {
            var currency = $('.scopes .selected a').text();
            var year = $(this).val();
            var url = '/admin/tax_holdback?currency=' + currency + '&year=' + year;
            window.location.href = url;
        });
        div.append(select);
        $('#index_table_tax_holdback').before(div);


        // total info
        var total_ele = $('.total-info');
        $('#index_table_tax_holdback tbody').append('<tr><td></td><td></td><td style="text-align:right;color:rgb(50, 53, 55);">Total:</td>' +
            '<td class="total-td">'+ total_ele.data('holdback-fed') +'</td>' +
            '<td class="total-td">'+ total_ele.data('holdback-state') +'</td></tr>');
    }
})