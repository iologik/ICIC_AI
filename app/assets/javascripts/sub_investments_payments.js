
$(function() {
    // payments page batch action, make a payment
    if($('.sub-investments-payments-page').length > 0) {
        var fistLi = $('.dropdown_menu_list li:first');
        // make a payment
        var makePayment = $('<li class="li-make-payment">Make a Payment</li>');
        fistLi.before(makePayment);
        // show popup
        $(document).on('click', '.li-make-payment', function(e){
            // get all sections
            var collectionSelection = [];
            var totalAmount = 0;
            var currency = null;
            var adminUserIds = [];
            $.each($('#index_table_sub_investment_payments tbody input:checked'), function(index, checkbox) {
                var tr = $(checkbox).closest('tr');
                collectionSelection.push($(checkbox).val());
                totalAmount += Number(tr.find('.col-amount').text().replace(/\$|,/g, ''));
                currency = tr.find('.col-currency').text();
                adminUserIds.push(tr.find('.admin_user_id').text().trim());
            });
            // popup
            var content = $('<form action="/admin/sub_investment_payments/make_payments" method="post">' +
                '<input name="collection_selection" type="hidden" value="'+ collectionSelection.toString() +'">' +
                '<fieldset class="inputs">' +
                '<legend><span>Make a Payment</span></legend>' +
                '<ol>' +
                '<li><label style="width: 100%;float: none;">Total amount $' + totalAmount.toFixed(2) + ' ' + currency + '</label></li>' +
                '<li class="string input optional stringish">' +
                '<input name="check_no" class="check-no" type="text" placeholder="Check No." />' +
                '</li>' +
                '<li class="string input optional stringish">' +
                '<input name="due_date" id="due_date_picker" type="text" placeholder="Due Date" />' +
                '</li>' +
                '<li>' +
                '<label style="width: 100%;float: none;"><input name="email" class="email" type="checkbox" value="true" /> Send sub-investor statement</label>' +
                '</li>' +
                '<fieldset class="actions" style="padding-left: 10px;margin:0;">' +
                '<ol>' +
                '<li class="action input_action ">' +
                '<input name="commit" type="submit" value="Update" class="make-payment"></li>' +
                '<li class="cancel"><a href="javascript:void(0)" class="close-popup">Cancel</a></li>' +
                '</ol>' +
                '</fieldset>' +
                '</ol>' +
                '</fieldset>' +
                '</form>');
            content.submit(function() {
                if(content.find('.email').is(':checked')) {
                    if($.unique(adminUserIds).length > 1) {
                        alert("Can not send mails to multiple users");
                        return false;
                    }
                }
            });

            var popupDiv = popup(content, null, []);
            $('body').css('overflow', 'hidden');
            popupDiv.fadeIn('fast');
            $("#due_date_picker").datepicker({
                dateFormat: "yy-mm-dd"
            });
            content.find('.check-no').click().focus();// click is for remove the batch action pop-up

            e.preventDefault();
            return false;
        });
    }
});
