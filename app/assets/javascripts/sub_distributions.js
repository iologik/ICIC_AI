$(function () {
    if ($('body.new.admin_sub_distributions.active_admin').length > 0 ||
        $('body.create.admin_sub_distributions.active_admin').length > 0) {

        // add transfer to new sub_investment
        var transfer_to_new_link = $('<a href="#" style="font-size:15px;">Transfer to a new sub-investment</a>');
        var space_label = $('<label>&nbsp;</label>');
        var transfer_to_new_li = $('<li class="string input optional stringish" style="display: none;"></li>');
        transfer_to_new_li.append(space_label);
        transfer_to_new_li.append(transfer_to_new_link);
        transfer_to_new_link.click(function(){
            var sub_investment_id = $('#sub_distribution_sub_investment_id').val();
            if(sub_investment_id == '' ) {
                alert('Please select a Sub investment first.');
                return;
            } else {
                var admin_user_id = $('#sub_distribution_current_admin_user_id').val();
                var url = "/admin/sub_investments/new?transfer_from=" + sub_investment_id + "&user=" + admin_user_id;
                window.location.href = url;
            }
        });
        $('#sub_distribution_transfer_to_id_input').before(transfer_to_new_li);

        // display transfer_to
        if ($('#sub_distribution_sub_distribution_type_transfer:checked').length > 0) {
            $('#sub_distribution_transfer_to_id_input').show();
            transfer_to_new_li.show();
        }

        // display transfer_to
        $('#sub_distribution_sub_distribution_type_transfer').click(function () {
            $('#sub_distribution_transfer_to_id_input').show();
            transfer_to_new_li.show();
        });
        // hide transfer_to
        $('#sub_distribution_sub_distribution_type_payment').click(function () {
            $('#sub_distribution_transfer_to_id').val(null);
            $('#sub_distribution_transfer_to_id_input').hide();
            transfer_to_new_li.hide();
        });

        // transfer_to sub_investments
        function transfer_to_sub_investments(sub_investment_id) {
            $.each($('#sub_distribution_transfer_to_id option'), function (i, v) {
                if (sub_investment_id.toString() == $(v).val().split('-')[1]) {
                    $(v).show();
                } else {
                    $(v).hide();
                }
            });
        }

        transfer_to_sub_investments($('#sub_distribution_sub_investment_id').val());

        $('#sub_distribution_sub_investment_id').change(function () {
            // clear
            $('#sub_distribution_transfer_to_id').val(null);

            // set transfer to sub_investments
            var sub_investment_id = $(this).val();
            transfer_to_sub_investments(sub_investment_id);
        });
    }

    // sub_distribution page http://localhost:3000/admin/sub_distributions?investment=24
    if($('#sub_distribution_amount_total').length > 0) {
        var amountTotal = $('#sub_distribution_amount_total').text();
        var dom_str = `
            <tr style="color:#000;"><td></td><td></td><td></td><td></td>
            <td style="text-align:right;color:rgb(50, 53, 55);">Total:</td>
            <td class="total-td">${amountTotal}</td>
            <td></td></tr>`;
        $('#sub_distribution_amount_total').closest('.index_as_table').find('tbody').append(dom_str);
    }
})