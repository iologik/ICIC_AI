$(function(){
    $(document).ready(function(){
        // investment retained total
        if($('.investment-cad-retained-total').length > 0) {
            var panel = $('.investment-cad-retained-total').closest('.index_as_table');
            var cadRetained = panel.find('.investment-cad-retained-total').text();
            var usdRetained = panel.find('.investment-usd-retained-total').text();

            panel.find('tbody').append(`<tr style="color:#000;">
                <td style="text-align:right;color:rgb(50, 53, 55);">Total:</td>
                <td class="total-td">${cadRetained}</td>
                <td class="total-td">${usdRetained}</td>
                <td></td></tr>`);
        }
    })
})
