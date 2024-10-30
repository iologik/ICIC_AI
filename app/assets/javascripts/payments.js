
$(function() {
    // payments page batch action, make a payment
    if($('.payments-page').length > 0) {
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
            var selectedPayments = $('#index_table_payments tbody input:checked');
            $.each(selectedPayments, function(index, checkbox) {
                var tr = $(checkbox).closest('tr');
                collectionSelection.push($(checkbox).val());
                totalAmount += Number(tr.find('.col-amount').text().replace(/\$|,/g, ''));
                currency = tr.find('.col-currency').text();
                adminUserIds.push(tr.find('.admin_user_id').text().trim());
            });
            // popup

            var d = new Date(),
                month = '' + (d.getMonth() + 1),
                day = '' + d.getDate(),
                year = d.getFullYear();

            if (month.length < 2)
                month = '0' + month;
            if (day.length < 2)
                day = '0' + day;

            var due_date_html = `
                <li class="string input optional stringish">
                    <label style="width: 100%;float: none;">Due Date</label>
                    <input name="due_date" id="due_date_picker" type="text" />
                </li>
            `;

            var firstPaymentType = selectedPayments.first().closest('tr').find('.col-payment_type').text();
            var dueEditablePayments = ['MISC', 'Transfer', 'Withdraw'];
            var due_date = selectedPayments.length == 1 && dueEditablePayments.includes(firstPaymentType) ? due_date_html : '';

            var content = $(`
                <form action="/admin/payments/make_payments" method="post">
                    <input name="collection_selection" type="hidden" value="${collectionSelection.toString()}">
                    <fieldset class="inputs">
                        <legend><span>Make a Payment</span></legend>
                        <ol>
                            <li><label style="width: 100%;float: none;">Total amount $${totalAmount.toFixed(2)} ${currency}</label></li>
                            <li class="string input optional stringish">
                                <label style="width: 100%;float: none;">Check No.</label>
                                <input name="check_no" class="check-no" type="text" />
                            </li>
                            ${due_date}
                            <li class="string input optional stringish">
                                <label style="width: 100%;float: none;">Paid Date</label>
                                <input name="paid_date" id="paid_date_picker" type="text" value="${[year, month, day].join('-')}"/>
                            </li>
                            <li>
                                <label style="width: 100%;float: none;">
                                    <input name="email" class="email" type="checkbox" value="true" /> Send sub-investor statement
                                </label>
                            </li>
                            <fieldset class="actions" style="padding-left: 10px;margin:0;">
                                <ol>
                                    <li class="action input_action ">
                                        <input name="commit" type="submit" value="Update" class="make-payment">
                                    </li>
                                    <li class="cancel"><a href="javascript:void(0)" class="close-popup">Cancel</a></li>
                                </ol>
                            </fieldset>
                        </ol>
                    </fieldset>
                </form>`);
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
            $("#paid_date_picker").datepicker({
                dateFormat: "yy-mm-dd"
            });
            content.find('.check-no').click().focus();// click is for remove the batch action pop-up

            e.preventDefault();
            return false;
        });

        $('.download_links a:first').html('CSV (Selection)')
        $(`<a href="/admin/payments.csv?scope=all_payments" target="_blank">CSV(All Payments)</a>`).insertAfter('.download_links a:first')
    }

    // display total payment amount
    if($('.total_payment_amount').length > 0) {
        var total_payment_amount_cad     = $('.total_payment_amount_cad.hide').text();
        var total_payment_amount_usd     = $('.total_payment_amount_usd.hide').text();
        var total_payment_amount_cad_all = $('.total_payment_amount_cad_all.hide').text();
        var total_payment_amount_usd_all = $('.total_payment_amount_usd_all.hide').text();
        var filteredCurrency = $('#q_currency').val();
        if (filteredCurrency != 'USD') {
            $('#index_table_payments').find('tbody').append(`<tr style="color:#000;"><td></td><td></td>
                <td colspan='2' style="text-align:right;color:rgb(50, 53, 55);">Total(CAD):</td>
                <td class="total-td">${total_payment_amount_cad}</td>
                </td><td></td><td></td><td></td><td></td><td></td></tr>`);
        }
        if (filteredCurrency != 'CAD') {
            $('#index_table_payments').find('tbody').append(`<tr style="color:#000;"><td></td><td></td>
                <td colspan='2' style="text-align:right;color:rgb(50, 53, 55);">Total(USD):</td>
                <td class="total-td">${total_payment_amount_usd}</td>
                </td><td></td><td></td><td></td><td></td><td></td></tr>`);
        }
        if (filteredCurrency != 'USD') {
            $('#index_table_payments').find('tbody').append(`<tr style="color:#000;"><td></td><td></td>
                <td colspan='2' style="text-align:right;color:rgb(50, 53, 55);">Total All Pages(CAD):</td>
                <td class="total-td">${total_payment_amount_cad_all}</td>
                </td><td></td><td></td><td></td><td></td><td></td></tr>`);
        }
        if (filteredCurrency != 'CAD') {
            $('#index_table_payments').find('tbody').append(`<tr style="color:#000;"><td></td><td></td>
                <td colspan='2' style="text-align:right;color:rgb(50, 53, 55);">Total All Pages(USD):</td>
                <td class="total-td">${total_payment_amount_usd_all}</td>
                </td><td></td><td></td><td></td><td></td><td></td></tr>`);
        }
    }

    if ($('.make-single-payment').length > 0) {
        $(document).on('click', '.make-single-payment', function(e){
            var paymentId = $('.payment-id td').text();
            var amount = Number($('.row-amount td').text().replace(/\$|,/g, ''));
            var currency = $('.payment-currency td').text();

            // popup
            var content = $(`
                <form action="/admin/payments/${paymentId}/make_single_payment" method="post">
                  <fieldset class="inputs">
                    <legend><span>Make a Payment</span></legend>
                    <ol>
                      <li><label style="width: 100%;float: none;">Amount $${amount.toFixed(2)} ${currency}</label></li>
                      <li class="string input optional stringish">
                        <input name="check_no" class="check-no" type="text" placeholder="Check No." />
                      </li>
                      <li class="string input optional stringish">
                        <input name="paid_date" id="paid_date_picker" type="text" placeholder="Paid Date" />
                      </li>
                      <li>
                        <label style="width: 100%;float: none;"><input name="email" class="email" type="checkbox" value="true" /> Send sub-investor statement</label>
                      </li>
                      <fieldset class="actions" style="padding-left: 10px;margin:0;">
                        <ol>
                          <li class="action input_action "><input name="commit" type="submit" value="Update" class="make-payment"></li>
                          <li class="cancel"><a href="javascript:void(0)" class="close-popup">Cancel</a></li>
                        </ol>
                      </fieldset>
                    </ol>
                  </fieldset>
                </form>`);

            var popupDiv = popup(content, null, []);
            $('body').css('overflow', 'hidden');
            popupDiv.fadeIn('fast');
            $("#due_date_picker").datepicker({
                dateFormat: "yy-mm-dd"
            });
            $("#paid_date_picker").datepicker({
                dateFormat: "yy-mm-dd"
            });
            content.find('.check-no').click().focus();// click is for remove the batch action pop-up

            e.preventDefault();
            return false;
        });
    }

    if ($('#new_payment').length > 0) {
      $('#payment_sub_investment_id').on('change', function(){
        var sub_investment_id = $(this).val();
        $('#payment_currency option').each(function(i, e){
          if(e.value && e.value.indexOf(sub_investment_id) > 0) {
            $(e).attr('selected', 'selected')
          }
        })
      })
    }

    if ($('.admin_payments').length > 0) {
      $('#q_admin_user_id').on('change', function() {
        if ($(this).val() == '') {
          $('#q_sub_investment_id option').css('display', 'block');
        } else {
          $.get('/admin/sub_investors/' + $(this).val() + '/sub_investment_ids', function (ids) {
            $('#q_sub_investment_id option').each(function(i, option) {
              if (ids.includes(parseInt($(option).val()))) {
                $(this).css('display', 'block');
              } else {
                $(this).css('display', 'none');
              }
            })

            $('#q_sub_investment_id').prop('selectedIndex',0);
          });
        }
      });

      $('#payment_admin_user_id').on('change', function() {
        if ($(this).val() == '') {
          $('#payment_sub_investment_id option').css('display', 'block');
        } else {
          $.get('/admin/sub_investors/' + $(this).val() + '/sub_investment_ids', function (ids) {
            $('#payment_sub_investment_id').empty();
            $('#payment_subinvestments_select option').each(function(i, option) {
              if (ids.includes(parseInt($(option).val()))) {
                $('#payment_sub_investment_id').append($(this));
              }
            })
          });
        }
      });

      // Copy all subinvestment data to other specific element
      var subinvestment_select = $('#payment_sub_investment_id').clone();
      subinvestment_select.attr('id', 'payment_subinvestments_select');
      subinvestment_select.attr('name', 'none');
      subinvestment_select.css('display', 'none');
      $('#new_payment').append(subinvestment_select);
      // $('#payment_sub_investment_id').empty();
    }

    // Disable Due Date Select
    if ($('#payment_due_date_input').length > 0 && window.location.href.endsWith("edit")) {
      $('input#payment_due_date').prop('disabled', true);
    }

    if($('.transfer_payment').length > 0) {
        $.each($('.transfer_payment'), function(index, transfer) {
            var paymentId = $(transfer).data("payment-id")
            var subInvestmentSelect = $('<select style="width:60%;" class="sub_investment_select"></select>');
            $.each($('.other-sub-investment[data-payment-id=' + paymentId + ']'), function(i, v) {
                subInvestmentSelect.append('<option value="' + $(v).data('id') + '" data-currency="' + $(v).data('currency') + '">'+ $(v).data('name') +'</option>');
            });

            var sourceCurrency = $(transfer).data('currency');
            var exchangeRateUsdCad = $(transfer).data('exchange-rate-usd-cad');
            var exchangeRateCadUsd = $(transfer).data('exchange-rate-cad-usd');

            var transferButton = $('#transfer_payment');
            var dom_str = `
                <form method="post" data-payment-id=${paymentId}>
                    <fieldset class="inputs">
                        <legend><span>Transfer Payment</span></legend>
                        <ol>
                            <li class="string input optional stringish"></li>
                            <li class="string input optional stringish">
                                <label style="width:30%;">To sub-investment</label>${subInvestmentSelect[0].outerHTML}
                            </li>
                            <li class="string input optional stringish li-exchange-rate">
                                <label style="width:30%;">Exchange Rate</label>
                                <input class="exchange_rate" type="number" step="0.00000000001" style="width:56%;">
                            </li>
                            <li class="string input optional stringish">
                                <label style="width:30%;">Email Subinvestor</label>
                                <input class="email_subinvester" type="checkbox">
                            </li>
                            <fieldset class="actions" style="padding-left: 10px;margin:0;">
                                <ol>
                                    <li class="action input_action ">
                                        <input name="commit" type="submit" value="Transfer" class="transfer-save">
                                    </li>
                                    <li class="cancel"><a href="javascript:void(0)" class="close-popup">Cancel</a></li>
                                </ol>
                            </fieldset>
                        </ol>
                    </fieldset>
                </form>`;
            var content = $(dom_str);
            popup(content, $(transfer), [['width', '40%'], ['left', '30%']]);

            var submit_transfer = false;

            setExchangeRate(paymentId)

            function setExchangeRate(paymentId) {
                var optionSelected = $("form[data-payment-id=" + paymentId + "] .sub_investment_select option:selected");
                var targetCurrency = optionSelected.data('currency');

                if (sourceCurrency == targetCurrency) {
                    $(".li-exchange-rate").css("display", "none")
                    $(".exchange_rate").val("1")
                } else {
                    $(".li-exchange-rate").css("display", "block")
                    if (sourceCurrency == 'USD') {
                        $(".exchange_rate").val(exchangeRateUsdCad)
                    } else {
                        $(".exchange_rate").val(exchangeRateCadUsd)
                    }
                }
            }

            $('.sub_investment_select').change(function() {
                setExchangeRate($(this).parents('form:first').data('payment-id'))
            })

            content.submit(function() {
                var paymentId = $(this).data('payment-id')
                if(submit_transfer) {
                    return false;
                }
                submit_transfer = true;
                $('.transfer-save').addClass('submit-transfer');
                var transferTo = $('form[data-payment-id=' + paymentId + '] .sub_investment_select option:selected').val();
                var exchangeRate = $('form[data-payment-id=' + paymentId + '] .exchange_rate').val();
                var emailSubinvestor = $('form[data-payment-id=' + paymentId + '] .email_subinvester').prop('checked');
                content.attr('action', '/admin/payments/'+ paymentId +'/transfer_to?transfer_to_id='+transferTo+'&exchange_rate='+exchangeRate+'&email_subinvestor='+emailSubinvestor);
            });
        })
    }

    // payments page
    if($('#index_table_payments').length > 0) {
      var thead = $('#index_table_payments').find('thead');
      $.each(thead.find('th'), function(index, th){
        $(th).css('width', $(th).width());
      });
    }
});
