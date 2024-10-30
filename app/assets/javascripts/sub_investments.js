$(function(){
    // s3 uploader
    var s3_uploader = $("#s3-uploader");
    var uploader = s3_uploader.S3Uploader({
      remove_completed_progress_bar: false,
      progress_bar_target: $(".formtastic.sub_investment"),
      before_add: function(file) {
        var types = /(\.|\/)(pdf)$/i;
        if(types.test(file.type) || types.test(file.name)) {
            return true;
        } else {
            alert("Please select a pdf file.")
            return false;
        }
      }
    });
    s3_uploader.bind("s3_uploads_start", function(e, content) {
      $(".formtastic.sub_investment input[type=submit]").hide();
    });
    s3_uploader.bind("s3_upload_complete", function(e, content) {
      $(".formtastic.sub_investment input[id=sub_investment_remote_agreement_url]").val(content.url);
      $(".formtastic.sub_investment input[type=submit]").show();
    });


    $.each($('.accrued-info'), function(index, element) {
      $(element).prepend("<label>" + $(element).data('amount') + "</label>");
    });

    $('.accrued-info').click(function() {
      var content = $(`
        <form action="#" method="post">
          <fieldset class="inputs">
            <legend><span>Accrued Calculation</span></legend>
            <ol>
              <li><label style="width: 100%;float: none;">${$(this).data('info')}</label></li>
              <fieldset class="actions" style="padding-left: 10px;margin:0;">
                <ol><li class="cancel"><a href="javascript:void(0)" class="close-popup-no-confirm">Close</a></li></ol>
              </fieldset>
            </ol>
          </fieldset>
        </form>`);

      var popupDiv = popup(content, null, []);
      $('body').css('overflow', 'hidden');
      popupDiv.fadeIn('fast');
      return false;
    });

    $.each($('.retained-info'), function(index, element) {
      $(element).prepend("<label>" + $(element).data('amount') + "</label>");
    });

    $('.retained-info').click(function() {
      var content = $(`
        <form action="#" method="post">
          <fieldset class="inputs">
            <legend><span>Interest Reserve Calculation</span></legend>
            <ol>
              <li><label style="width: 100%;float: none;">${$(this).data('info')}</label></li>
              <fieldset class="actions" style="padding-left: 10px;margin:0;">
                <ol><li class="cancel"><a href="javascript:void(0)" class="close-popup-no-confirm">Close</a></li></ol>
              </fieldset>
            </ol>
          </fieldset>
        </form>`);

      var popupDiv = popup(content, null, []);
      $('body').css('overflow', 'hidden');
      popupDiv.fadeIn('fast');
      return false;
    });

    // payments page batch action, make a payment
    if($('.payment-batch-action').length > 0) {
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
        var subInvestmentId = $('#current_sub_investment_id').data('id');
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
            <form action="/admin/sub_investments/${subInvestmentId}/payment_batch_action" method="post">
                <input name="collection_selection" type="hidden" value="${collectionSelection.toString()}">
                <input name="batch_action" type="hidden" value="mark_as_paid">
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
    }

    if ($('form.sub_investment').length > 0) {
      $('#sub_investment_currency_input fieldset').append(`
          <div class="current-exchange-rate-wrapper">
            <div>Current USD Exchange:<span class="underline">${$('#sub_investment_exchange_rate').data('rate')}</span></div>
            <div>Current CAD Exchange:<span class="underline">${$('#sub_investment_exchange_rate').data('cad-usd-rate')}</span></div>
          </div>`);
    }

    if ($('.admin_sub_investments.index').length > 0) {
      var admin_user_id = $($('#current_user_profile a')[0]).attr('href').split('/')[3]
      $.ajax('/admin/sub_investments/sub_investment_ids?admin_user_id=' + admin_user_id).then(function(response){
        var isAdmin = response.is_admin;
        var sub_investment_ids = response.sub_investment_ids;

        if (!isAdmin) {
          $.each($('#q_id option'), function(index, option){
            if ($(option).val() && sub_investment_ids.indexOf(parseInt($(option).val())) == -1) {
              $(option).remove();
            }
            if ($(option).html().trim() == '') {
              $(option).remove();
            }
          })

          $.each($('#q_admin_user_id option'), function(index, option){
              var currentUserIds = $('#current-users').data('ids') + ""
              if (currentUserIds.split(",").length == 1) {
                $(option).remove();
              }
          })
          if ($('#q_admin_user_id option').length == 0) {
            $('#q_admin_user_id').append(`
              <option value="${$($('#current_user_profile a')[0]).attr('href').split('/')[3]}">${$($('#current_user a')[0]).html()}</option>`);
          }


          var admin_user_id = $($('#current_user_profile a')[0]).attr('href').split('/')[3]
          $.ajax('/admin/sub_investments/sub_investment_ids?admin_user_id=' + admin_user_id).then(function(sub_investment_ids){
            $.each($('#q_id option'), function(index, option){
              if ($(option).val() && sub_investment_ids.indexOf(parseInt($(option).val())) == -1) {
                $(option).remove();
              }
              if ($(option).html().trim() == '') {
                $(option).remove();
              }
            })
          })

          $.each($('#q_investment_id option'), function(index, option){
            var currentUserInvestmentIds = $('#current-user-investments').data('ids') + ""
            if ($(option).val() && currentUserInvestmentIds.indexOf($(option).val()) == -1) {
              $(option).remove();
            }
          })
        } else {
          $('label[for="q_id"]').remove();
          $('select#q_id').remove();
        }
      })
    }

    $('#transaction_report').click(function(e) {
      var sub_investment_id = $(this).data('id');
      var min_date = $(this).data('start-date');
      var min_year = min_date.slice(0, 4);

      const yourDate = new Date();
      var today = yourDate.toISOString().split('T')[0];
      
      var form = `
        <form action='/admin/sub_investments/${sub_investment_id}/transaction_report' method='get' class='transaction_report'>
          <div style='margin: auto; width: 450px;'>
            <div style='text-align:center; width: 100%; padding-bottom: 20px;'><h2>Investment Transaction Ledger</h2></div>
            <div class='date-from' style='overflow: auto;'>
              <label style='font-size: 20px; width: 40%; float: left;'>Start Date: </label>
              <div style='width: 60%; float: left;'>
                <input type='text' name='date_from'>
              </div>
            </div>
            <div class='date-to' style='padding-top: 20px;'>
              <label style='font-size: 20px; width: 40%; float: left;'>End Date: </label>
              <div style='width: 60%; float: left;'>
                <input type='text' name='date_to'>
              </div>
            </div>
            <fieldset class="actions" style="padding-left: 10px;margin:0;">
              <ol style='width: 210px; margin: auto; padding-top: 40px;'>
                <li class="action input_action ">
                  <input name="commit" type="submit" value="Generate Report" class="make-payment">
                </li>
                <li class="cancel">
                  <a href="javascript:void(0)" class="close-popup">Cancel</a>
                </li>
              </ol>
            </fieldset>
          </div>
        </form>`;
      var content = $(form);
      $(document).on('click', '.transaction_report', function(e){
      })
      popupDiv = popup(content, null, [['width', '500px']]);
      $("[name='date_from']").datepicker({ dateFormat: "yy-mm-dd" });
      $("[name='date_to']").datepicker({ dateFormat: "yy-mm-dd" });
      $('body').css('overflow', 'hidden');
      popupDiv.fadeIn('fast');
      e.stopPropagation();
    });

    if ($('#charge_fee').length > 0) {
        // current sub-investment id
      var currentSubInvestmentId = $('#current_sub_investment_id').data('id');
      var lastTransferDate = $('#last_transfer_date').data('value');
      var startTransferDate = $('#start_transfer_date').data('value');
      var chargeFeeAmount = $('#default_charge_fee_amount').data('value');

      var dom_str = `
          <form method="post" class="charge-fee-form">
            <fieldset class="inputs">
              <legend><span>Charge Fee</span></legend>
              <ol>
                <li class="string input optional stringish">
                  <label style="width:30%;">Amount</label>
                  <input name="amount" value="${chargeFeeAmount}" id="charge_fee_amount" min="0" step="any" type="number" style="width:56%;">
                </li>
                <li style='overflow: auto;'>
                  <label style="width:30%;">Date<br> (after ${startTransferDate} and before ${lastTransferDate})<abbr title="required">*</abbr></label>
                  <ol class='fragments-group' style='float: left;'><input type="text" id="due_date"></ol>
                </li>
                <li class="string input optional stringish">
                  <label style="width:30%;">Email Subinvestor</label>
                  <input class="email_subinvester" type="checkbox">
                </li>
                <fieldset class="actions" style="padding-left: 10px;margin:0;">
                  <ol>
                    <li class="action input_action ">
                      <input name="commit" type="submit" value="Charge Fee" class="charge-fee-save">
                    </li>
                    <li class="cancel"><a href="javascript:void(0)" class="close-popup">Cancel</a></li>
                  </ol>
                </fieldset>
              </ol>
            </fieldset>
          </form>`;
      var content = $(dom_str);
      popup(content, $('#charge_fee'), [['width', '40%'], ['left', '30%']]);
      $('#due_date').datepicker({ dateFormat: "yy-mm-dd" });

      var submit_charge_fee = false;
      $('.charge-fee-save').click(function() {
        if(submit_charge_fee) { return false; }
        var amount = Number($('#charge_fee_amount').val());
        if(amount == 0) {
          alert('Please enter amount');
          return false;
        }
        var due_date_str = $('#due_date').val();
        if(!due_date_str) {
          alert('Please enter date');
          return false;
        }
        var due_date = Date.parse(due_date_str);
        if(due_date < Date.parse(startTransferDate)) {
          alert('The transfer date can not be before ' + startTransferDate);
          return false;
        }
        if(due_date > Date.parse(lastTransferDate)) {
          alert('The transfer date can not be after ' + lastTransferDate);
          return false;
        }
        submit_charge_fee = true;
        var emailSubinvestor = $('.charge-fee-form .email_subinvester').prop('checked');
        var amount = $('.charge-fee-form #charge_fee_amount').val();
        var url = `/admin/sub_investments/${currentSubInvestmentId}/charge_fee?email_subinvestor=${emailSubinvestor}&due_date=${due_date_str}&amount=${amount}`;
        content.attr('action', url);
        content.submit();
        return false;
      });
    }

    // amount_change_panel of sub-investment
    if($('#amount_change_panel').length > 0) {
      var amountChangeIn = $('#amount_change_in').data('value');
      var amountChangeOut = $('#amount_change_out').data('value');
      var amountChangeBalance = $('#amount_change_balance').data('value');
      var dom_html = `<tr style="color:#000;"><td></td>
          <td style="text-align:right;color:rgb(50, 53, 55);">Total:</td>
          <td class="total-td">${amountChangeIn}</td>
          <td class="total-td">${amountChangeOut}</td>
          <td class="total-td">${amountChangeBalance}</td>
          </tr>`;
      $('#amount_change_panel').find('tbody').append(dom_html);
    }

    // Make New SubInvestment Button Dialog Popup Configuration
    if ($('#new_sub_investment').length > 0) {
      var content = $(`
        <form data-remote="true">
          <fieldset class="inputs">
            <legend><span>Initial Description</span></legend>
            <ol>
              <li class="string input optional stringish">
                <input class="initial-description"/>
              </li>
              <li class="input optional">
                <label>
                  <input type="checkbox" name="notify" class="notify-investor"/>
                  Notify To Investor
                </label>
                <br>
              </li>
              <li class="action input_action ">
                <input name="commit" type="submit" value="OK" class="">
              </li>
              <li class="cancel">
                <a href="javascript:void(0)" class="close-initial-description-popup">Cancel</a>
              </li>
            </ol>
          </fieldset>
        </form>`);
      content.submit(function() {
        var initialDescription = $('.initial-description').val();
        var notifyInvestor     = $('.notify-investor').prop('checked');

        $('.initial-description-wrapper').append('<input id="sub_investment_initial_description" name="sub_investment[initial_description]" value="' + initialDescription + '" />')
        $('.initial-description-wrapper').append('<input id="sub_investment_notify" name="sub_investment[is_notify_investor]" value="' + notifyInvestor + '" />')
        $('.popup-background').fadeOut('fast');
        $('body').css('overflow', 'visible');
        $('#new_sub_investment').submit()
      });

      var popupDiv = popup(content, null, []);

      $('body').on('click', '.close-initial-description-popup', function () {
        popupDiv.fadeOut('fast');
        $('body').css('overflow', 'visible');
      });

      $('#new_sub_investment').on('submit', function(){
        if (!$('#sub_investment_creation_date').val()) {
          alert('start date field is required!');
          return false;
        }
        if ($('#sub_investment_initial_description').length == 0) {
          $('body').css('overflow', 'hidden');
          popupDiv.fadeIn('fast');
          return false;
        }
      })
    }

    if ($('#upload-signed-agreement').length > 0) {
      var upload_form_str = `
        <form method="post" enctype="multipart/form-data" action="/admin/sub_investments/${currentSubInvestmentId}/upload_signed_agreement">
          <fieldset class="inputs">
            <legend><span>Upload Signed Agreement</span></legend>
            <label style="width:30%;">Select File</label>
            <input type="file" name="signed_agreement" accept="application/pdf">
            <fieldset class="actions" style="padding-left: 10px;margin:0;">
              <ol>
                <li class="action input_action ">
                  <input name="upload" type="submit" value="Upload" class="upload-agreement">
                </li>
                <li class="cancel"><a href="javascript:void(0)" class="close-popup">Cancel</a></li>
              </ol>
            </fieldset>
          </fieldset>
        </form>`;
      var upload_form_html = $(upload_form_str);
      popup(upload_form_html, $('#upload-signed-agreement'), [['width', '40%'], ['left', '30%']]);

      $('.upload-agreement').click(function() {
        var url = `/admin/sub_investments/${currentSubInvestmentId}/upload_signed_agreement`;
        upload_form_html.attr('action', url);
        upload_form_html.submit();
        return false;
      });
    }

    // display referrand_form_panel
    if($('#referrand_form_panel').length > 0) {
      referrand_panel = $('#referrand_form_panel');
      referrand_panel.before('<div id="referrand_checkbox_div"><label for="referrand_checkbox"><input id="referrand_checkbox" type="checkbox" value="1"> Display AMF Panel</label></div>');
      $('#referrand_checkbox').change(function(){
        if(this.checked) {
          referrand_panel.fadeIn('fast');
        } else {
          referrand_panel.fadeOut('fast');
        }
      });
    }

    // payments page batch action, make a payment
    if($('#transfer_sub_investment').length > 0) {
      // current sub-investment id
      var currentSubInvestmentId = $('#current_sub_investment_id').data('id');
      // other sub-investments select
      var subInvestmentSelect = $('<select style="width:60%;" id="sub_investment_select"></select>');
      var accountType = '';
      $.each($('.other-sub-investment'), function(i, v) {
          if (i == 0) {
              accountType = $(v).data('account-type');
          }
          subInvestmentSelect.append('<option value="' + $(v).data('id') + '"data-account-type="' + $(v).data('account-type') + '"data-end-date="' + $(v).data('end-date') + '">'+ $(v).data('name') +'</option>');
      });
      // max transfer amount
      var maxTransferAmount = $('#max_sub_investment_amount').data('value');
      // last transfer date
      var lastTransferDate = $('#last_transfer_date').data('value');
      // popup
      var transferButton = $('#transfer_sub_investment');
      var today = new Date();
      var today_str = today.toISOString().split('T')[0];
      var dom_str = `
          <form method="post">
            <fieldset class="inputs">
              <legend><span>Transfer Sub-investment</span></legend>
              <ol style="display:flex; flex-direction: column;">
                <li class="string input optional stringish">
                  <a href="${transferButton.data('url')}" style="font-size:15px;">Transfer to a new sub-investment</a>
                </li>
                <li class="string input optional stringish">
                  <hr>
                </li>
                <li class="string input optional stringish">
                  <label style="font-size:15px;width:100%;">Transfer to an existing sub-investment</label>
                </li>
                <li class="string input optional stringish"></li>
                <li class="string input optional stringish">
                  <label style="width:30%;">To sub-investment</label>${subInvestmentSelect[0].outerHTML}
                </li>
                <li class="string input optional stringish">
                  <label style="width:30%;">Account Type</label>
                  <span class="sub-investment-account-type">${accountType}</span>
                </li>
                <li class="string input optional stringish">
                  <label style="width:30%;">Amount<br> (up to ${maxTransferAmount})<abbr title="required">*</abbr></label>
                  <input id="sub_investment_amount" min="0" step="any" type="number" style="width:56%;">' +
                </li>
                <li class="string input optional stringish">
                  <label style="width: 30%;">Check No.</label>
                  <input name="check_no" class="check-no" type="text" style="width:56%;"/>
                </li>
                <li>
                  <label style="width:30%;">Date<br> (before <span class="last-transfer-date">${lastTransferDate}</span>)<abbr title="required">*</abbr></label>
                  <ol class='fragments-group' style='float: left;'><input type="text" value="${today_str}" id="transfer_date"></ol>
                </li>
                <li>
                  <label style="width: 100%;float: none;"><input name="notify_investor" id="notify-investor" type="checkbox" value="true" />Notify Investor</label>
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
      popup(content, $('#transfer_sub_investment'), [['width', '80%'], ['left', '30%']]);
      $('#transfer_date').datepicker({ dateFormat: "yy-mm-dd"});

      $('#sub_investment_select').on('change', function() {
          $('.sub-investment-account-type').html($('#sub_investment_select option:selected').data('account-type'));

          var endDate = $('#sub_investment_select option:selected').data('end-date');
          $('.last-transfer-date').html(endDate < lastTransferDate ? endDate : lastTransferDate)
      });

      var submit_transfer = false;
      $('.transfer-save').click(function() {
        if(submit_transfer) { return false; }
        var amount = Number($('#sub_investment_amount').val());
        if(amount == 0) {
          alert('Please enter amount');
          return false;
        }
        if(amount > maxTransferAmount) {
          alert('The max transfer amount is ' + maxTransferAmount);
          return false;
        }
        var transfer_date = $('#transfer_date').val();
        if(!transfer_date) {
          alert('Please enter date');
          return false;
        }
        if(Date.parse(transfer_date) > Date.parse(lastTransferDate)) {
          alert('The transfer date can not be after ' + lastTransferDate);
          return false;
        }
        submit_transfer = true;
        $(this).addClass('submit-transfer');
        var transferTo = $('#sub_investment_select').val();
        var notifyInvestor = $('#notify-investor').val();
        var url = `/admin/sub_investments/${currentSubInvestmentId}/transfer_to?transfer_to_id=${transferTo}&amount=${amount}&transfer_date=${transfer_date}&is_notify_investor=${notifyInvestor}`;
        content.attr('action', url);
        content.submit();
        return false;
      });
    }

    /*----- Change 3 separate date input(year, month, date) to datepicker -----*/

    // On new subinvestment page, change date to datepicker
    if ($('#sub_investment_paid_date').length > 0) {
      $('#sub_investment_paid_date').datepicker({ dateFormat: "yy-mm-dd"});
    }

    if ($('#sub_investment_due_date').length > 0) {
      $('#sub_investment_due_date').datepicker({ dateFormat: "yy-mm-dd"});
    }

    if ($('#sub_investment_start_date_input').length > 0) {
      // Take date data
      const date_val  = $('#sub_investment_start_date').val();

      $("body #sub_investment_start_date").datepicker({ dateFormat: "yy-mm-dd" });
      if (date_val) {
        $("body #sub_investment_start_date").datepicker('setDate', date_val);
      }
    }

    const refreshDateInput = () => {
      $('[id*="sub_investment_interest_periods_attributes_"]').each(function(index){
        const self_id = $(this).attr('id');
        if (self_id.includes('_effect_date_input')) {
          const id = $(this).attr('id').match(/\d+/);
          const input_id = `sub_investment_interest_periods_attributes_${id}_effect_date`;

          if ($(`#${input_id}`).length === 0) {
            $(this).html(`
              <label for="sub_investment_interest_periods_attributes_${id}_effect_date" class="label">Effect Date</label>
              <input id="${input_id}" type="text" name="sub_investment[interest_periods_attributes][${id}][effect_date]">
              `);
          }
          const class_val = $(`body #${input_id}`).attr('class');
          if ($(`body #${input_id}`).length > 0 && !(class_val && class_val.includes('hasDatepicker'))) {
            $(`body #${input_id}`).datepicker({ dateFormat: "yy-mm-dd" });
          }
        }
      });
    }

    refreshDateInput();

    if ($('a[data-placeholder="NEW_INTEREST_PERIOD_RECORD"]').length > 0) {
      const nipr = 'NEW_INTEREST_PERIOD_RECORD';
      let html_data = $(`a[data-placeholder="${nipr}"]`).attr('data-html');
      const input_id = `sub_investment_interest_periods_attributes_${nipr}_effect_date`;
      let field_set = $(html_data);

      const effect_date_input_template = field_set.find('#sub_investment_interest_periods_attributes_NEW_INTEREST_PERIOD_RECORD_effect_date_input');
      const old_form = effect_date_input_template.prop('outerHTML');
      effect_date_input_template.html(`
          <label for="sub_investment_interest_periods_attributes_${nipr}_effect_date" class="label">Effect Date</label>
          <input id="${input_id}" type="text" name="sub_investment[interest_periods_attributes][${nipr}][effect_date]">
          `);
      const new_field_set = effect_date_input_template.prop('outerHTML');
      html_data = html_data.replace(old_form, new_field_set);
      $(`a[data-placeholder="${nipr}"]`).attr('data-html', html_data);
    }

    $('a[data-placeholder="NEW_INTEREST_PERIOD_RECORD"]').click(function() {
      setTimeout(()=>{
        refreshDateInput();
      }, 1000);
    })

    /*----- Change 3 separate date input(year, month, date) to datepicker end -----*/
});
