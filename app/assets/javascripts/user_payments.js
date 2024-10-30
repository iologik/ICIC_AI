$(function(){
    $(document).ready(function(){
        // Add Total row to user payments page
        if($('.user-payment-total').length > 0) {
            var panel = $('.user-payment-total').closest('.index_as_table');
            var amountTotal = panel.find('.user-payment-total').text();

            var dom_str = '';
            var diff = '';
            if($('body.sub-investor').length == 0) {
                diff = '<td></td>';
            }
            dom_str = `<tr style="color:#000;">
                    <td></td><td></td><td></td><td></td>${diff}
                    <td style="text-align:right;color:rgb(50, 53, 55);">Total:</td>
                    <td class="total-td">${amountTotal}</td>
                    <td></td><td></td><td></td><td></td></tr>`;
            panel.find('tbody').append(dom_str);
        }

        // year name
        if($('.scopes .current_year_cad').length > 0) {
            function replaceYearText(e, text, year) {
                var count = e.text().replace(text, '');
                if(count.trim() == '(0)') {
                    e.closest('li').remove();
                } else {
                    e.text(year).append($('<span class="count">' + count + '</span>'));
                }
            }

            var scope = $('.scopes');
            var year = new Date().getFullYear();
            replaceYearText(scope.find('.current_year_cad a'), 'Current Year Cad', year + ' CAD');
            replaceYearText(scope.find('.last_year_cad a'), 'Last Year Cad', (year - 1).toString() + " CAD");
            replaceYearText(scope.find('.before_last_year_cad a'), 'Before Last Year Cad', (year - 2).toString() + " CAD");
            replaceYearText(scope.find('.three_years_aog_cad a'), 'Three Years Ago Cad', (year - 3).toString() + " CAD");
            replaceYearText(scope.find('.current_year_usd a'), 'Current Year Usd', year + ' USD');
            replaceYearText(scope.find('.last_year_usd a'), 'Last Year Usd', (year - 1).toString() + " USD");
            replaceYearText(scope.find('.before_last_year_usd a'), 'Before Last Year Usd', (year - 2).toString() + " USD");
            replaceYearText(scope.find('.three_years_ago_usd a'), 'Three Years Ago Usd', (year - 3).toString() + " USD");
        }
    });
})
