$(function () {
    // sub-investment and investment pages both need these images
    if ($('.images-content').length > 0) {
        var investment_id = $('.images-content').text().trim();

        $.get('/admin/investments/' + investment_id + '/images_panel', function (data) {
            $('.images-content').after($(data.page));

            $(".modal-has-image-gallery").on("show.bs.modal", function (e) {
                $(this).addClass("active");
                $(this).css("display", "flex");
            });
        });

        $(document).on("click", ".modal-inner, .modal .carousel .item", function (e) {
            if (e.target != this) return;
            $(this).closest(".modal").modal("hide");
        });
    };

    manageExchangeRate();

    function manageExchangeRate() {
      var currency = 'USD'
      $('input[name="investment[currency]"]').each(function(i, e) {
        if (e.checked) {
          currency = e.value
        }
      })
      if (currency == 'USD') {
        $('#investment_exchange_rate_input').removeClass('hide')
      } else {
        $('#investment_exchange_rate_input').addClass('hide')
      }
    }

    $('input[name="investment[currency]"]').on('click', function() {
      manageExchangeRate();
    })

    if ($('#new_investment, #edit_investment').length > 0) {
      $('#investment_currency_input fieldset').append('<div class="current-exchange-rate-wrapper"><div>Current USD Exchange:<span class="underline">' + $('.current_exchange_rate').data('rate') + '</span></div><div>Current CAD Exchange:<span class="underline">' + $('.current_exchange_rate').data('cad-usd-rate') + '</span></div></div>')
    }

    // investment show page filter

    function addFilterToSubInvestmentPanel() {
      var panel = $('#investment_sub_investments');
      var filterBox = $('<div class="filter-box float-right pt-7"></div>');

      filterBox.append("<label class='filter-label'>Filters:</label>");

      // state filters
      var stateFilters = $('<a href="#" class="filter-link active" data-state="active">Active</a>' +
                           '<a href="#" class="filter-link archived" data-state="archived">Archived</a>' +
                           '<a href="#" class="filter-link all" data-state="all">All</a>');
      filterBox.append(stateFilters);
      // state filter event
      filterBox.find('.filter-link').click(function(){
          $(this).closest('.filter-box').find('.filter-link').removeClass('selected');
          $(this).addClass('selected');
          // filter
          adjustSubInvestmentPanelInfo();
      });
      panel.before(filterBox);
    }

    addFilterToSubInvestmentPanel();

    function adjustSubInvestmentPanelInfo() {
      var state = $('.filter-box').find('.filter-link.selected').data('state');

      $.each($('#investment_sub_investments').find('table tbody tr'), function(i, tr) {
          var trLink = $(tr).find('td.col-name a');
          var trState = trLink.data('state');

          if(state != 'all' && state != trState) {
              $(tr).addClass('must-hide');
          } else {
              $(tr).removeClass('must-hide');
          }
      });
      // $('#sub_investor_icic_investments').find('tbody tr.total-info-tr').remove();
    }

    // Set Default Status to Active
    $('.filter-link.active[data-state="active"]').click();

    // investments page
    if($('#index_table_investments').length > 0) {
        var thead = $('#index_table_investments').find('thead');
        $.each(thead.find('th'), function(index, th){
            $(th).css('width', $(th).width());
        });
    }

    // investments index page
    if($('.real-investment-index').length > 0) {
        $('#q_investment_status_id').val(3);
    }

    // popup box for edit-investment-amount
    if($('.edit-investment-amount').length > 0) {
        var content = $(`
            <form>
                <fieldset class="inputs">
                    <legend><span>Increase Amount</span></legend>
                    <ol>
                        <li class="string input optional stringish">
                            <input maxlength="255" id="increase_amount_input" type="number" value="0" placeholder="Increase Amount">
                        </li>
                        <fieldset class="actions" style="padding-left: 10px;margin:0;">
                            <ol>
                                <li class="action input_action ">
                                    <input name="commit" type="submit" value="Update" class="increase-amount"></li>
                                <li class="cancel"><a href="javascript:void(0)" class="close-popup">Cancel</a></li>
                            </ol>
                        </fieldset>
                    </ol>
                </fieldset>
            </form>`);
        popup(content, $('.edit-investment-amount'), []);

        $('.increase-amount').click(function() {
            var number = $('#increase_amount_input').val() - 0;
            $('#investment_amount').val($('#investment_amount').val() - 0 + number);
            $('#investment_ori_amount').val($('#investment_ori_amount').val() - 0 + number);
            closePopup();
            return false;
        });
    }

    // investment_distributions sum
    if($('#investment_distribution_draws').length != 0) {
        if($('.return_of_capital.hide').length > 0) {
            var capital_amount = $('.return_of_capital.hide').text();
            var withholding_tax_amount = $('.withholding_tax.hide').text();
            var holdback_state_amount = $('.holdback_state.hide').text();
            var gross_amount = $('.gross_profit.hide').text();
            var cash_reserve_amount = $('.hide.cash_reserve').text();
            var net_cash_amount = $('.hide.net_cash').text();
            var draw_amount = $('.draw-amount').text();
            var balance = $('.current_amount').text();

            var panel = $('#investment_distribution_draws');
            panel.find('table tbody').append('<tr style="color:#000;"><td></td><td style="text-align:right;color:rgb(50, 53, 55);">Total:</td><td class="total-td">'+ withholding_tax_amount +'</td><td class="total-td">'+ holdback_state_amount +'</td><td class="total-td">'+ gross_amount +'</td><td class="total-td">'+ cash_reserve_amount +'</td><td class="total-td">'+ net_cash_amount +'</td><td class="total-td">'+capital_amount+'</td><td class="total-td">'+ draw_amount+'</td><td class="total-td">'+ balance +'</td><td></td><td></td></tr>');
        }
    }

    // sub_investment statistics info
    if($('#investment_sub_investments').length != 0) {
        if($('.sub_amount_total.hide').length > 0) {
            var sub_amount_total = $('.sub_amount_total.hide').text();
            var sub_ownership_percent_sum = $('.sub_ownership_percent_sum.hide').text();
            var sub_per_annum_avg = $('.sub_per_annum_avg.hide').text();
            var sub_accrued_percent_avg = $('.sub_accrued_percent_avg.hide').text();
            var sub_current_accrued_sum = $('.sub_current_accrued_sum.hide').text();
            var sub_retained_percent_avg = $('.sub_retained_percent_avg.hide').text();
            var sub_current_retained_sum = $('.sub_current_retained_sum.hide').text();

            var panel = $('#investment_sub_investments');
            var content = '<tr style="color:#000;"><td>&nbsp;</td><td>&nbsp;</td>';
            if($('#investment_sub_investments').hasClass('imor')){
                // there is account column
                content += '<td>&nbsp;</td>';
            }
            content += `
                <td></td>
                <td style="text-align:right;color:rgb(50, 53, 55);">Total:</td>
                <td class="total-td">${sub_ownership_percent_sum}</td>
                <td class="total-td">${sub_amount_total}</td>
                <td></td>
                <td class="total-td">${sub_per_annum_avg}</td>
                <td class="total-td">${sub_current_accrued_sum}<br><span style="font-size: 0.6rem">(Avg ${sub_accrued_percent_avg})</span></td>
                <td class="total-td">${sub_current_retained_sum}<br><span style="font-size: 0.6rem">(Avg ${sub_retained_percent_avg})</span></td>
                <td>&nbsp;</td></tr>`
            panel.find('table tbody').append(content);
        }
    }

    if ($('#new_investment').length > 0) {
      var investmentSources = '<select class="filter-select investment-sources">';

      $.each($('#investment_investment_source_id option'), function(i, v) {
          investmentSources += '<option value="' + $(v).attr('value') + '">'+ $(v).html() +'</option>';
      });
      investmentSources += '</select>'

      var dom_str = `
          <form data-remote="true">
            <fieldset class="inputs">
              <legend><span>Select your investment source</span></legend>
              <ol>
                <li class="string input optional stringish">${investmentSources}</li>
                <li class="action input_action "><input name="commit" type="submit" value="OK" class=""></li>
                <li class="cancel"><a href="javascript:void(0)" class="close-investment-source-popup">Cancel</a></li>
              </ol>
            </fieldset>
          </form>`;
      var content = $(dom_str);
      content.submit(function() {
        var investmentSource = $('.investment-sources option:selected').val()
        $('#investment_investment_source_id').val(investmentSource)
        $('.popup-background').fadeOut('fast');
        $('body').css('overflow', 'visible');
      });

      $('body').on('click', '.close-investment-source-popup', function () {
        window.location.href = window.location.protocol + "//" + window.location.host + "/admin/investments"
      });

      var popupDiv = popup(content, null, []);
      $('body').css('overflow', 'hidden');
      popupDiv.fadeIn('fast');
    }

    if ($('#new_investment').length > 0) {
      var dom_str = `
          <form data-remote="true">
            <fieldset class="inputs">
              <legend><span>Initial Description</span></legend>
              <ol>
                <li class="string input optional stringish">
                  <input class="initial-description"/>
                </li>
                <li class="action input_action ">
                  <input name="commit" type="submit" value="OK" class="">
                </li>
                <li class="cancel">
                  <a href="javascript:void(0)" class="close-initial-description-popup">Cancel</a>
                </li>
              </ol>
            </fieldset>
          </form>`;
      var content = $(dom_str);
      content.submit(function() {
        var initialDescription = $('.initial-description').val();
        var dom_str = `<input id="investment_initial_description" name="investment[initial_description]" value="${initialDescription}" />`;
        $('.initial-description-wrapper').append(dom_str);
        $('.popup-background').fadeOut('fast');
        $('body').css('overflow', 'visible');
        $('#new_investment').submit()
      });

      var popupDiv = popup(content, null, []);

      $('body').on('click', '.close-initial-description-popup', function () {
        popupDiv.fadeOut('fast');
        $('body').css('overflow', 'visible');
      });

      $('#new_investment').on('submit', function(){
        if ($('#investment_initial_description').length == 0) {
          $('body').css('overflow', 'hidden');
          popupDiv.fadeIn('fast');
          return false;
        }
      })
    }

    // investment page total info
    if($('.investment-page.amount-total').length > 0) {
        if($('.filter-currency').length > 0) {
            var totalCurrency = $('.filter-currency').data('currency');
        } else {
            var totalCurrency = 'CAD';
        }

        var panel = $('.investment-page.amount-total').closest('.index_as_table');

        var amountTotal = panel.find('.amount-total').text();
        var moneyRaisedTotal = Number(panel.find('.money-raised-total').text().trim());
        var cashReserveTotal = Number(panel.find('.cash-reserve-total').text().trim());
        var balanceTotal = Number(panel.find('.balance-total').text().trim());

        var amountTotalUSD      = panel.find('.amount-total-usd').text();
        var moneyRaisedTotalUSD = Number(panel.find('.money-raised-total-usd').text().trim());
        var balanceTotalUSD     = Number(panel.find('.balance-total-usd').text().trim());

        var amountTotalCAD      = panel.find('.amount-total-cad').text();
        var moneyRaisedTotalCAD = Number(panel.find('.money-raised-total-cad').text().trim());
        var balanceTotalCAD     = Number(panel.find('.balance-total-cad').text().trim());

        var amountTotalUSDAll      = panel.find('.amount-total-usd-all').text();
        var moneyRaisedTotalUSDAll = Number(panel.find('.money-raised-total-usd-all').text().trim());
        var balanceTotalUSDAll     = Number(panel.find('.balance-total-usd-all').text().trim());

        var amountTotalCADAll      = panel.find('.amount-total-cad-all').text();
        var moneyRaisedTotalCADAll = Number(panel.find('.money-raised-total-cad-all').text().trim());
        var balanceTotalCADAll     = Number(panel.find('.balance-total-cad-all').text().trim());

        var currentUSDHtml = `<tr style="color:#000;">
            <td style="text-align:right;color:rgb(50, 53, 55);">Total(USD):</td>
            <td class="total-td">${amountTotalUSD}</td>
            <td class="total-td">$${moneyRaisedTotalUSD.formatMoney()}</td>
            <td class="total-td"></td>
            <td class="total-td">$${balanceTotalUSD.formatMoney()}</td>
            <td>Currency in USD</td>
            <td></td><td></td></tr>`;
        var currentCADHtml = `<tr style="color:#000;">
            <td style="text-align:right;color:rgb(50, 53, 55);">Total(CAD):</td>
            <td class="total-td">${amountTotalCAD}</td>
            <td class="total-td">$${moneyRaisedTotalCAD.formatMoney()}</td>
            <td class="total-td"></td>
            <td class="total-td">$${balanceTotalCAD.formatMoney()}</td>
            <td>Currency in CAD</td>
            <td></td><td></td></tr>`;
        var allUSDHtml     = `<tr style="color:#000;">
            <td style="text-align:right;color:rgb(50, 53, 55);">Total All Pages(USD):</td>
            <td class="total-td">${amountTotalUSDAll}</td>
            <td class="total-td">$${moneyRaisedTotalUSDAll.formatMoney()}</td>
            <td class="total-td"></td>
            <td class="total-td">$${balanceTotalUSDAll.formatMoney()}</td>
            <td>Currency in USD</td>
            <td></td><td></td></tr>`;
        var allCADHtml     = `<tr style="color:#000;">
            <td style="text-align:right;color:rgb(50, 53, 55);">Total All Pages(CAD):</td>
            <td class="total-td">${amountTotalCADAll}</td>
            <td class="total-td">$${moneyRaisedTotalCADAll.formatMoney()}</td>
            <td class="total-td"></td>
            <td class="total-td">$${balanceTotalCADAll.formatMoney()}</td>
            <td>Currency in CAD</td>
            <td></td><td></td></tr>`;

        var filteredCurrency = $('#q_currency').val();
        if (filteredCurrency != 'CAD') {
            panel.find('tbody').append(currentUSDHtml);
        }
        if (filteredCurrency != 'USD') {
            panel.find('tbody').append(currentCADHtml);
        }

        // adjustments
        if($('.filter-currency').length > 0) {
            var amount = Number($('.filter-currency').text().trim());
            var amountMoney = amount.formatMoney();
            panel.find('tbody').append(`<tr style="color:#000;">
                <td style="text-align:right;color:rgb(50, 53, 55);">K&R Adjustments:</td><td></td>
                <td class="total-td">-$${amountMoney}</td>
                <td class="total-td"></td>
                <td class="total-td">$${amountMoney}</td>
                <td></td><td></td><td></td></tr>`);

            panel.find('tbody').append(`<tr style="color:#000;">
                <td style="text-align:right;color:rgb(50, 53, 55);">NET TOTAL:</td>
                <td class="total-td">${amountTotal}</td>
                <td class="total-td">$${(moneyRaisedTotal - amount).formatMoney()}</td>
                <td class="total-td"></td>
                <td class="total-td">$${(balanceTotal + amount).formatMoney()}</td>
                <td></td><td></td><td></td></tr>`);
        }

        if (filteredCurrency != 'CAD') {
            panel.find('tbody').append(allUSDHtml);
        }
        if (filteredCurrency != 'USD') {
            panel.find('tbody').append(allCADHtml);
        }
    }

    $(document).ready(function(){
      $('#detailed_report').on('click', function(){
        var investmentId = $('#info').data('id');

        var distributionDraws = '<select>';
        distributionDraws += '<option value="all">All</option>';
        var minDate = maxDate = null;
        $.each($('.distribution-draw'), function(i, v) {
          distributionDraws += '<option value="' + $(v).data('id') + '" data-date="' + $(v).data('date') + '">'+ $(v).data('name') +'</option>';
          var date = $(v).data('date')
          if (!minDate || minDate > date) {
              minDate = date
          };
          if (!maxDate || maxDate < date) {
              maxDate = date
          }
        });

        distributionDraws += '</select>'


        var transactionTypes = `
          <div class="transaction-type-wrapper">
            <fieldset class="choices">
              <label><input type="checkbox" name="transaction_type[]" value="FED"> FED</label>
              <label><input type="checkbox" name="transaction_type[]" value="STATE"> STATE</label>
              <label><input type="checkbox" name="transaction_type[]" value="GROSS PROFIT"> GROSS PROFIT</label>
              <label><input type="checkbox" name="transaction_type[]" value="CASH RESERVE"> CASH RESERVE</label>
              <label><input type="checkbox" name="transaction_type[]" value="NET CASH"> NET CASH</label>
              <label><input type="checkbox" name="transaction_type[]" value="RETURN OF CAPITAL"> RETURN OF CAPITAL</label>
              <label><input type="checkbox" name="transaction_type[]" value="CAPITAL INVESTED"> CAPITAL INVESTED</label>
            </fieldset>
          </div>`;

        var contentHtml = `
          <form id="investment-statement-form" method="post">
            <fieldset class='inputs'>
              <ol>
                <li>
                  <div>
                    <label>Start Date</label>
                    <ol class='fragments-group'>${dateSelect('start')}</ol> - 
                  </div>
                  <br/>
                  <div>
                    <label>End Date</label>
                    <ol class='fragments-group'>${dateSelect('end')}</ol>
                  </div>
                  <br/>
                  <br/>
                </li>
                <li><label style="width: 100%;float: none;">What type of Transaction do you want listed?</label></li>
                <li>${transactionTypes}</li>
                <li>
                  <fieldset class='actions' style='padding-left: 10px;margin:0;'>
                    <ol>
                      <li class="action input_action ">
                        <input name="commit" type="submit" value="Generate Report" class="make-payment">
                      </li>
                      <li class="cancel"><a href="javascript:void(0)" class="close-popup">Cancel</a></li>
                    </ol>
                  </fieldset>
                </li>
              </ol>
            </fieldset>
          </form>`;
        var content = $(contentHtml);
        content.submit(function(e) {
          var investmentId     = $('#info').data('id');
          var transactionTypes = $('#investment-statement-form .transaction-type-wrapper input:checked').val();

          if (!transactionTypes) {
            alert('DO NOT GENERATE A BLANK REPORT');
            e.preventDefault();
            return;
          }

          var start_str = $('#start-date').val();
          var end_str   = $('#end-date').val();
          debugger;
          var start = new Date(start_str);
          var end   = new Date(end_str);

          if (start > end) {
            alert('End date must be later than start date');
            e.preventDefault();
            return;
          }

          $('#investment-statement-form').attr('action', '/admin/investments/' + investmentId + '/generate_report');
        });

        var popupDiv = popup(content, null, []);
        $('#start-date').datepicker({ dateFormat: "yy-mm-dd" });
        $('#end-date').datepicker({ dateFormat: "yy-mm-dd" });
        $('body').css('overflow', 'hidden');
        popupDiv.fadeIn('fast');
      });

      var dateSelect = function(prefix) {
        return `<input name="${prefix}_date_str" id="${prefix}-date" type="text" placeholder="${prefix} date" />`;
      }
    });

})
