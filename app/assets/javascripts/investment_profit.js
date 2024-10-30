$(function () {
    if ($('body.admin_investment_profits').length > 0) {
        //scope currencies
        var scope_content = $('.scopes-content');

        var accumulated = (scope_content.data('accumulated') == true);

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
                var accumulated_flag = $('#accumulated_flag').is(':checked');
                var url = '/admin/investment_profits?currency=' + currency + '&year=' + year+"&accumulated=" + accumulated_flag;
                window.location.href = url;
            });
            li.append(link);
            ul.append(li);
        });
        div.append(ul);
        // scope years
        var years = $.parseJSON(scope_content.text().trim());
        if(accumulated) {
            var select = $('<select id="scope_year" style="height:auto;margin-left: 5px;display: none;"></select>');
        } else {
            var select = $('<select id="scope_year" style="height:auto;margin-left: 5px;"></select>');
        }
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
            var accumulated_flag = $('#accumulated_flag').is(':checked');
            var url = '/admin/investment_profits?currency=' + currency + '&year=' + year+"&accumulated=" + accumulated_flag;
            window.location.href = url;
        });
        div.append(select);
        // by year
        var accumulated_label = $('<label for="accumulated_flag" style="margin-left: 15px;"></label>');
        if(accumulated) {
            var accumulated_checkbox = $('<input id="accumulated_flag" type="checkbox" checked>');
        } else {
            var accumulated_checkbox = $('<input id="accumulated_flag" type="checkbox">');
        }
        accumulated_checkbox.change(function() {
            if($(this).is(':checked')) {
                $('#scope_year').hide();
            } else {
                $('#scope_year').show();
            }
            var currency = $('.scopes .selected a').text();
            var year = $('#scope_year').val();
            var accumulated_flag = $('#accumulated_flag').is(':checked');
            var url = '/admin/investment_profits?currency=' + currency + '&year=' + year+"&accumulated=" + accumulated_flag;
            window.location.href = url;
        });
        accumulated_label.append(accumulated_checkbox);
        accumulated_label.append(' Accumulated');
        div.append(accumulated_label);
        $('#index_table_investment_profits').before(div);

        // total info
        var initial_amount_total = $('.initial_amount_total').text();
        var current_amount_total = $('.current_amount_total').text();
        var gross_profit_total = $('.gross_profit_total').text();
        var all_paid_payments_amount = $('.all_paid_payments_amount').text();
        var sub_balance = $('.sub_balance').html();
//        var accrued_payable_total = $('.accrued_payable_total').text();
//        var net_income = $('.net_income').html();
//        var retained_payable_total = $('.retained_payable_total').text();
//        var net_income = $('.net_income').html();

        $('#index_table_investment_profits tbody').append('<tr style="color:#000;"><td></td>' +
            (accumulated ? '' : '<td></td>') +
            '<td style="text-align:right;color:rgb(50, 53, 55);">Total:</td>' +
            '<td class="total-td">' + initial_amount_total + '</td>' +
            '<td class="total-td">' + current_amount_total + '</td>' +
            '<td class="total-td">' + gross_profit_total + '</td>' +
            '<td class="total-td">' + all_paid_payments_amount + '</td>' +
            '<td class="total-td">' + sub_balance + '</td>'// +
//            '<td class="total-td">' + accrued_payable_total + '</td>' +
//            '<td class="total-td">' + retained_payable_total + '</td>' +
//            '<td class="total-td">' + net_income + '</td></tr>'
        );

        // freeze table head
        window.invest.freeze_thead($('#index_table_investment_profits'));


    }
})