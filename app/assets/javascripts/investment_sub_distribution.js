$(function(){
    $(document).ready(function(){
        // investment sub distribution page
        if($('.usd_sub_distribution_amount').length > 0) {
            var usdSubDistribution = $('.usd_sub_distribution_amount').text();
            var cadSubDistribution = $('.cad_sub_distribution_amount').text();
            var dom_str = `<tr style="color:#000;">
                <td style="text-align:right;color:rgb(50, 53, 55);">Total:</td>
                <td class="total-td">${cadSubDistribution}</td>
                <td class="total-td">${usdSubDistribution}</td></tr>`;
            $('.usd_sub_distribution_amount').closest('.index_as_table').find('tbody').append(dom_str);
        }
    });
})
