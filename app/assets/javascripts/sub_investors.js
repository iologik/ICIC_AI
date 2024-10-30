$(document).ready(function(){
  let current_sort_class = '';
  let sortable_classes;
  if ($('body.admin_sub_investors').length > 0) {
    sortable_classes = ['col-paid_date', 'col-due_date'];
  }
  if ($('body.admin_sub_investments').length > 0) {
    sortable_classes = ['col-paid_date', 'col-due_date', 'col-amount', 'col-payment_type'];
  }

  // initialize sort column headers
  if (sortable_classes) {
    sortable_classes.forEach(function(sort_class){
      $(`.custom_sort_table thead tr th.${sort_class}`).each(function(i, obj){
        $(this).addClass('sortable');
        let column_txt = $(this).text();
        $(this).html(`<a href="#">${column_txt}</a>`);
      });
  
      $('.custom_sort_table').on('click', `tr th.${sort_class}`, function(e) {
        // switch class between  'sorted-desc', 'sorted-asc'
        if ($(this).hasClass('sorted-desc')) {
          $(this).removeClass('sorted-desc');
          $(this).addClass('sorted-asc');
          sort($(this), sort_class);
        }
        else if ($(this).hasClass('sorted-asc')) {
          $(this).removeClass('sorted-asc');
          $(this).addClass('sorted-desc');
          sort($(this), sort_class, true);
        }
        else {
          $(this).addClass('sorted-asc');
          sort($(this), sort_class);
        }
        e.preventDefault();
      })
    })
  }

  function sort(column_head, sort_class, reverse = false){
    let table = column_head.closest('table');
    let tbody = table.find('tbody');
    let rows  = table.find('tbody tr');
    table.find('tbody tr').remove();
    current_sort_class = sort_class
    let sorted_rows = [];
    if (sort_class == 'col-paid_date' || sort_class == 'col-due_date') {
      sorted_rows = rows.sort(compare_row);
    }
    else if (sort_class == 'col-amount') {
      sorted_rows = rows.sort(compare_row_by_amount);
    }
    else if (sort_class == 'col-payment_type') {
      sorted_rows = rows.sort(compare_row_by_string);
    }
    if (reverse) {
      temp_array = [];
      for (var i = sorted_rows.length - 1; i >= 0; i--) {
        temp_array.push(sorted_rows[i]);
      }
      sorted_rows = temp_array;
    }
    for (var i = sorted_rows.length - 1; i >= 0; i--) {
      if (i % 2 == 0) {
        $(sorted_rows[i]).removeClass('even');
        $(sorted_rows[i]).removeClass('odd');
        $(sorted_rows[i]).addClass('odd');
      }
      else {
        $(sorted_rows[i]).removeClass('odd');
        $(sorted_rows[i]).removeClass('even');
        $(sorted_rows[i]).addClass('even');
      }
      tbody.prepend(sorted_rows[i]);
    }
  }

  function compare_row(a, b){
    date_a_str = $(a).find(`.${current_sort_class}`).text();
    date_b_str = $(b).find(`.${current_sort_class}`).text();
    if (!date_a_str) {
      return -1;
    }
    if (!date_b_str) {
      return 1;
    }
    if (!date_a_str && !date_b_str) {
      return 0;
    }

    date_a_obj = new Date(date_a_str);
    date_b_obj = new Date(date_b_str);
    if (date_a_obj > date_b_obj) {
      return -1;
    }
    if (date_a_obj < date_b_obj) {
      return 1;
    }
    return 0;
  }

  function compare_row_by_amount(a, b){
    date_a_str = $(a).find(`.${current_sort_class}`).text();
    date_b_str = $(b).find(`.${current_sort_class}`).text();
    if (!date_a_str) {
      return -1;
    }
    if (!date_b_str) {
      return 1;
    }
    if (!date_a_str && !date_b_str) {
      return 0;
    }

    date_a_obj = Number(date_a_str.replace(/[^0-9.-]+/g,""));
    date_b_obj = Number(date_b_str.replace(/[^0-9.-]+/g,""));;
    if (date_a_obj > date_b_obj) {
      return -1;
    }
    if (date_a_obj < date_b_obj) {
      return 1;
    }
    return 0;
  }

  function compare_row_by_string(a, b){
    date_a_str = $(a).find(`.${current_sort_class}`).text();
    date_b_str = $(b).find(`.${current_sort_class}`).text();
    if (!date_a_str) {
      return -1;
    }
    if (!date_b_str) {
      return 1;
    }
    if (!date_a_str && !date_b_str) {
      return 0;
    }

    if (date_a_str > date_b_str) {
      return -1;
    }
    if (date_a_str < date_b_str) {
      return 1;
    }
    return 0;
  }

  $('#investor_transaction_report').click(function(e) {
    var sub_investor_id = $(this).data('id');
    var currency = $(this).data('currency');
    var min_date = $(this).data('start-date');
    var min_year = min_date.slice(0, 4);

    const yourDate = new Date();
    var today = yourDate.toISOString().split('T')[0];
    
    var form = `
      <form action='/admin/sub_investors/${sub_investor_id}/transaction_report' method='get' class='transaction_report'>
        <div style='margin: auto; width: 500px;'>
          <div style='text-align:center; width: 100%; padding-bottom: 20px;'><h1>Investor Transaction Ledger</h1></div>
          <div class='date-from' style='overflow: auto;'>
            <label style='font-size: 18px; width: 40%; float: left;'>Start Date: </label>
            <div style='width: 60%; float: left;'>
              <input type='text' name='date_from' id='transaction_ledger_date_from'>
            </div>
          </div>
          <div class='date-to' style='padding-top: 20px; overflow: auto;'>
            <label style='font-size: 18px; width: 40%; float: left;'>End Date: </label>
            <div style='width: 60%; float: left;'>
              <input type='text' name='date_to' id='transaction_ledger_date_to'>
            </div>
          </div>
          <div class='currency' style='padding-top: 20px; overflow: auto;'>
            <label style='font-size: 18px; width: 40%; float: left;'>Currency: </label>
            <div style='width: 60%; float: left; display: flex;'>
              ${currencySelect(currency)}
            </div>
          </div>
          <div class='investmentSource' style='padding-top: 20px; overflow: auto;'>
            <label style='font-size: 18px; width: 40%; float: left;'>Investment Sources: </label>
            <div style='width: 60%; float: left; display: flex;'>
              ${investmentSourceSelect()}
            </div>
          </div>
          <fieldset class="actions" style="padding-left: 10px;margin:0;">
            <ol style='width: 210px; margin: auto;'>
              <li class="action input_action ">
                <input name="commit" type="submit" value="Generate Report" class="make-payment">
              </li>
              <li class="cancel">
                <a href="javascript:void(0)" class="close-popup">Cancel</a>
              </li>
            </ol>
          </fieldset>
        </div>
      </form>`
    var content = $(form);
    popupDiv = popup(content, null, [['width', '540px']]);
    content.submit(function(e) {
      var investmentSource = $('.investmentSource .investment-source-wrapper input:checked').val();
      if (!investmentSource) {
        alert('DO NOT GENERATE A BLANK REPORT');
        e.preventDefault();
        return;
      }

      var dateFrom = $('#transaction_ledger_date_from').val();
      if (!dateFrom) {
        alert('Start Date must be provided');
        e.preventDefault();
        return;
      }
      var dateFromObj = Date.parse(dateFrom);

      var dateTo = $('#transaction_ledger_date_to').val();
      if (!dateTo) {
        alert('End Date must be provided');
        e.preventDefault();
        return;
      }
      var dateToObj = Date.parse(dateTo);

      if (dateFromObj > dateToObj) {
        alert('End Date must be after Start Date');
        e.preventDefault();
        return false;
      }

      if (dateToObj > today) {
        alert('End Date must be in the past');
        e.preventDefault();
        return false;
      }
    });
    $('body').css('overflow', 'hidden');
    $("[name='date_from']").datepicker({ dateFormat: "yy-mm-dd" });
    $("[name='date_to']").datepicker({ dateFormat: "yy-mm-dd" });
    popupDiv.fadeIn('fast');
    e.stopPropagation();
  });

  var currencySelect = function(currency) {
    var currencies = currency.split(', ');
    return currencies.reduce(function(total, currency, index){
      return total + `
        <div style='width: 50%;'>
          <input type='radio' id='${currency}-Currency' name='currency' value='${currency}' style='width: 20px; height: 20px;' ${index == 0 ? 'checked':''}>
          <label for='${currency}-Currency' style='font-size: 20px;'>${currency}</label>
        </div>
      `
    }, []);
  }

  var investmentSourceSelect = function(){
    var investmentSources = '<div class="investment-source-wrapper" style="margin-top: 0"><fieldset class="choices" style="padding-top: 0;">';

    $.each($('.investment-source'), function(i, v) {
      id = $(v).data('id');
      name = $(v).data('name');
      investmentSources += `<label for="q_investment_source_id_${id}">
        <input type="checkbox" 
               name="investment_source[]" 
               value="${id}" 
               id="q_investment_source_id_${id}"
               data-investment-source-name="${name}">
        ${name}
      </label><br/>`;
    });
    investmentSources += '</fieldset></div>';

    return investmentSources;
  }

  // total info on sub-investor page, icic investments
  if($('#sub_investor_icic_investments').length > 0) {
    function addTotalToSubInvestments(currency) {
      var amount_total = 0;
      var per_annum_total = 0;//
      var referrand_percent_total = 0;//
      var accrued_per_annum_total = 0;//
      var current_accrued_total = 0;
      var retained_per_annum_total = 0;//
      var current_retained_total = 0;

      $.each($('#sub_investor_icic_investments').find('table tbody tr'), function(i, tr) {
        if($(tr).hasClass('must-hide')) {
            return;
        }

        var trLink = $(tr).find('td.col-name a');
        var lineCurrency = trLink.data('currency');

        if (currency == lineCurrency) {
          var tempAmount = Number(trLink.data('amount'));
          amount_total += tempAmount;
          per_annum_total += Number(trLink.data('per-annum')) * tempAmount;
          referrand_percent_total += (Number(trLink.data('referrand-percent')) || 0) * tempAmount;
          accrued_per_annum_total += Number(trLink.data('accrued-per-annum')) * tempAmount;
          current_accrued_total += Number(trLink.data('current-accrued'));
          retained_per_annum_total += Number(trLink.data('retained-per-annum')) * tempAmount;
          current_retained_total += Number(trLink.data('current-retained'));
        }
      });

      var per_annum_average = per_annum_total / amount_total
      var referrand_percent_average = referrand_percent_total / amount_total
      var accrued_per_annum_average = accrued_per_annum_total / amount_total
      var retained_per_annum_average = retained_per_annum_total / amount_total

      var dom_str = `
        <tr style="color:#000;" class="total-info-tr">
          <td></td>
          <td style="text-align:right;color:rgb(50, 53, 55);">Total:</td>
          <td class="total-td">$${amount_total.formatMoney()}</td>
          <td>${currency}</td>
        </tr>`;
      $('#sub_investor_icic_investments').find('tbody').append(dom_str);
    }

    function makePanelInfo() {
      var state = $('.filter-box').find('.filter-link.selected').data('state');
      var currency = $('.filter-box').find('.currency:checked').val();
      var investmentSource = []
      $.each($('.filter-box').find('[name="investment_source[]"]:checked'), function(i, source){
        investmentSource.push(parseInt($(source).val()))
      });

      $.each($('#sub_investor_icic_investments').find('table tbody tr'), function(i, tr) {
        var trLink = $(tr).find('td.col-name a');
        var trCurrency = trLink.data('currency');
        var trState = trLink.data('state');
        var trInvestmentSource = trLink.data('investment-source');

        if(state != 'all' && state != trState) {
          $(tr).addClass('must-hide');
        } else if(currency != 'all' && currency != trCurrency) {
          $(tr).addClass('must-hide');
        } else if (investmentSource.indexOf(trInvestmentSource) == -1) {
          $(tr).addClass('must-hide');
        } else {
          $(tr).removeClass('must-hide');
        }
      });
      $('#sub_investor_icic_investments').find('tbody tr.total-info-tr').remove();
      addTotalToSubInvestments('CAD');
      addTotalToSubInvestments('USD');

      $.each($('.upcoming-payments-panel'), function(i, upcomingPaymentsPanel) {
        var amount_total = 0;
        $.each($(upcomingPaymentsPanel).find('table tbody tr'), function(i, tr) {
          var trLink = $(tr).find('td.col-sub_investment a');
          var trInvestmentSource = trLink.data('investment-source');

          if (investmentSource.indexOf(trInvestmentSource) == -1) {
              $(tr).addClass('must-hide');
          } else {
              $(tr).removeClass('must-hide');
              amount_total += Number(trLink.data('amount'));
          }
        })

        $(upcomingPaymentsPanel).find('tbody tr.total-info-tr').remove();
        var dom_str = `
          <tr style="color:#000;" class="total-info-tr">
            <td></td>
            <td style="text-align:right;color:rgb(50, 53, 55);">Total:</td>
            <td class="total-td">$${amount_total.formatMoney()}</td>
          </tr>`;
        $(upcomingPaymentsPanel).find('tbody').append(dom_str);
      });


      // $('#upcoming-payments-panel').find('tbody tr.total-info-tr').remove();
      // addTotalToSubInvestments('CAD');
      // addTotalToSubInvestments('USD');
    }

    var panel = $('#sub_investor_icic_investments');
    var filterBox = $('<div class="filter-box"></div>');

    filterBox.append("<label class='filter-label'>Filters:</label>");

    // state filters
    var dom_str = `<a href="#" class="filter-link active" data-state="active">Active</a>
                   <a href="#" class="filter-link archived" data-state="archived">Archived</a>
                   <a href="#" class="filter-link all" data-state="all">All</a>`;
    var stateFilters = $(dom_str);
    filterBox.append(stateFilters);
    // state filter event
    filterBox.find('.filter-link').click(function(){
        $(this).closest('.filter-box').find('.filter-link').removeClass('selected');
        $(this).addClass('selected');
        // filter
        makePanelInfo();
    });

    // currency filters
    var currency_str = `<label class="filter-label" style="margin-left: 20px;margin-right:0;">Currency: </label>
                        <label class="filter-label"><input type="radio" value="CAD" class="currency" name="currency" /> CAD</label>
                        <label class="filter-label"><input type="radio" value="USD" class="currency" name="currency" /> USD</label>
                        <label class="filter-label"><input type="radio" value="all" class="currency" name="currency" checked /> All</label>`;
    var currencyFilters = $(currency_str);
    filterBox.append(currencyFilters);
    // currency filter event
    filterBox.find('.currency').click(function(){
        makePanelInfo(); // filter
    });

    filterBox.append("<label class='filter-label'>Investment Source:</label>");

    var initialSelectedSources = ['Van Haren Investment Corp.', 'Innovation Capital Investment USA Inc.', 'Innovation Capital Investment Corp.', 'Imor']
    var investmentSources = '<div class="sub-investor-investment-source-wrapper"><fieldset class="choices">';
    var investmentSourcesInOrder = []
    var investmentSourcesData = {}

    $.each($('.investment-source'), function(i, v) {
      investmentSourcesData[$(v).data('name')] = $(v).data('id')
      investmentSourcesInOrder.push($(v).data('name'));
    });

    $.each(investmentSourcesInOrder, function(i,name) {
      id = investmentSourcesData[name];
      investmentSources += `<label for="q_investment_source_id_${id}" style="white-space: nowrap;"><input type="checkbox" name="investment_source[]" value="${id}"`;
      if (initialSelectedSources.indexOf(name) > -1) {
        investmentSources += ' checked';
      }
      investmentSources += `>${name}</label>`;
    });
    investmentSources += '</fieldset></div>';

    filterBox.append(investmentSources);


    filterBox.find('[name="investment_source[]"]').change(function(){
      makePanelInfo(); // filter
      changePanelTitle();
    });

    panel.before(filterBox);

    if(panel.find('.active-default').length > 0) {
      filterBox.find('.active').addClass('selected');
      makePanelInfo();
    } else if(panel.find('.archived-default').length > 0) {
      filterBox.find('.archived').addClass('selected');
      makePanelInfo();
    } else if(panel.find('.all-default').length > 0) {
      filterBox.find('.all').addClass('selected');
      makePanelInfo();
    }

    function changePanelTitle() {
      var investmentSourceName = $('.filter-box').find('.investment-sources option:selected').html();
      if (investmentSourceName == 'RRSP') {
        if ($('#sub_investor_imor_investments h3').length > 0) {
          var title = $('#sub_investor_imor_investments h3').html()
          title = title.replace('Imor', 'RRSP')
          $('#sub_investor_imor_investments h3').html(title)
        }

        if ($('.upcoming-payments-panel h3').length > 0) {
          title = $('.upcoming-payments-panel h3').html()
          title = title.replace('Imor', 'RRSP')
          $('.upcoming-payments-panel h3').html(title)
        }
      }
    }
  }

  // display upcomiing payment amount total in sub-investor(admin_user) page
  if($('.upcoming-payments-panel').length > 0) {
    function getCurrentAmount(currentAmount) {
      return `<tr style="color:#000;"><td></td>
          <td style="text-align:right;color:rgb(50, 53, 55);">Sub-Total:</td>
          <td class="total-td">$${currentAmount.formatMoney(2)}</td>
          <td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>`;
    }

    function addSubTotal(accountLink, currentId, currentAmount) {
      if(currentId) {
          accountLink.closest('tr').before(getCurrentAmount(currentAmount));
      }
    }

    function addSubTotalAfter(accountLink, currentId, currentAmount) {
      if(currentId) {
          accountLink.closest('tr').after(getCurrentAmount(currentAmount));
      }
    }
  }

  // edit sub investor password
  if($('#edit_sub_investor_password').length > 0) {
    var passwordPanel = $('#edit_sub_investor_password');
    // display checkbox
    var checked = '';
    if(passwordPanel.find('.required.password.error').length != 0) {
      // checked checkbox
      checked = ' checked';
    }
    var dom_str = `<div id="password_checkbox_div"><label for="password_checkbox"><input id="password_checkbox" type="checkbox"${checked}> Display Password Panel</label></div>`;
    passwordPanel.before(dom_str);
    $('#password_checkbox').change(function(){
      if(this.checked) {
        passwordPanel.insertBefore($('.actions'));
      } else {
        passwordPanel.remove();
      }
    });
    // remove passwordPanel if there is no error
    if(passwordPanel.find('.required.password.error').length == 0) {
      passwordPanel.remove();
    }
  }

  // Sub Investor Statement Report
  if ($('.sub-investor-statement').length > 0) {
    $(document).on('click', '.sub-investor-statement', function(e){
      var subInvestorId = $('.sub-investor-id').data('id')
      var subInvestments = '<select class="filter-select sub-investments">';

      subInvestments += '<option value="all">All</option>';
      var minStartDate = maxEndDate = null;
      var today = new Date();
      $.each($('.sub-investment-option'), function(i, v) {
          subInvestments += '<option value="' + $(v).data('id') + '" data-start-date="' + $(v).data('start-date') + '" data-end-date="' + $(v).data('end-date') + '">'+ $(v).data('name') +'</option>';
          var startDate = new Date($(v).data('start-date'));
          var endDate = new Date($(v).data('end-date'));
          if (!minStartDate || minStartDate > startDate) {
              minStartDate = startDate
          };
          if (!maxEndDate || maxEndDate < endDate) {
              maxEndDate = endDate
              if (maxEndDate > today) {
                  maxEndDate = today;
              }
          }
      });

      subInvestments += '</select>'

      var investmentSources = '<div class="investment-source-wrapper"><fieldset class="choices">';

      $.each($('.investment-source'), function(i, v) {
        investmentSources += '<label for="q_investment_source_id_' + $(v).data('id') + '"><input type="checkbox" name="investment_source[]" value="' + $(v).data('id') + '" data-investment-source-name="' + $(v).data('name') + '">' + $(v).data('name') + '</label>'
      });
      investmentSources += '</fieldset></div>';

      var investmentStatus = `<div class="investment-status-wrapper"><fieldset class="choices">
        <label><input type="checkbox" name="investment_status[]" value="active">ACTIVE</label>
        <label><input type="checkbox" name="investment_status[]" value="archived">ARCHIVED</label>
        <label><input type="checkbox" name="investment_status[]" value="future">FUTURE</label>
        </fieldset></div>`;

      var paymentKind = `<div class="payment-kind-wrapper"><fieldset class="choices">
        <label><input type="checkbox" name="payment_kind[]" value="Principal">Principal</label>
        <label><input type="checkbox" name="payment_kind[]" value="Withdraw">Withdraw</label>
        <label><input type="checkbox" name="payment_kind[]" value="Interest">Interest</label>
        <label><input type="checkbox" name="payment_kind[]" value="Accrued">Accrued</label>
        <label><input type="checkbox" name="payment_kind[]" value="Retained">Interest Reserve</label>
        <label><input type="checkbox" name="payment_kind[]" value="AMF">AMF</label>
        <label><input type="checkbox" name="payment_kind[]" value="Transfer">Transfer</label>
        <label><input type="checkbox" name="payment_kind[]" value="RRSP">RRSP</label>
        <label><input type="checkbox" name="payment_kind[]" value="MISC">MISC</label>
        </fieldset></div>`;

      var content = $(`
        <form class="sub-investor-statement-form" method="post">
          <fieldset class="inputs">
            <legend><span>Select your sub investment</span></legend>
            <div class="accrued-retained-report-title">
              This report will sum together all selected payment types that have been paid related to the investments listed within the requested date range.
            </div>
            <ol>
              <input id="sub-investment-id" name="sub_investment_id" type="hidden" />
              <li class="string input optional stringish">
                ${subInvestments}
              </li>
              <li>
                <label style="width: 100%;float: none;">DATE RANGE</label>
                <div class="date-from">
                  <input name="date_from" id="date-from" type="text" />
                </div> - <div class="date-to">
                  <input name="date_to" id="date-to" type="text" />
                </div>
              </li>
              <input id="investment-source-id" name="investment_source_id" type="hidden" />
              <li><label style="width: 100%;float: none;">INVESTMENT SOURCE</label></li>
              <li class="string input optional stringish">${investmentSources}</li>
              <li><label style="width: 100%;float: none;">INVESTMENT STATUS </label></li>
              <li>${investmentStatus}</li>
              <li><label style="width: 100%;float: none;">Payment Type </label></li>
              <li>${paymentKind}</li>
              <li>
                <label style="width: 100%;float: none;">
                  <input name="email" class="email" type="checkbox" value="true" /> Send sub-investor statement
                </label>
              </li>
              <fieldset class="actions" style="padding-left: 10px;margin:0;">
                <ol>
                  <li class="action input_action ">
                    <input name="commit" type="submit" value="Generate Report" class="make-payment">
                  </li>
                  <li class="cancel"><a href="javascript:void(0)" class="close-popup">Cancel</a></li>
                </ol>
              </fieldset>
            </ol>
          </fieldset>
        </form>`);
      content.submit(function(e) {
        var subInvestment = $('.sub-investor-statement-form .sub-investments option:selected').val();
        var investmentSource = $('.sub-investor-statement-form .investment-source-wrapper input:checked').val();
        var investmentStatus = $('.sub-investor-statement-form .investment-status-wrapper input:checked').val();
        var paymentKind = $('.sub-investor-statement-form .payment-kind-wrapper input:checked').val();

        if (subInvestment == 'all' && (!investmentSource || !investmentStatus || !paymentKind)) {
          alert('DO NOT GENERATE A BLANK REPORT');
          e.preventDefault();
          return;
        }

        if (subInvestment != 'all' && !paymentKind) {
          alert('DO NOT GENERATE A BLANK REPORT');
          e.preventDefault();
          return;
        }

          $('.sub-investor-statement-form #sub-investment-id').val(subInvestment)
          $('.sub-investor-statement-form #investment-source-id').val(investmentSource)

          var dateFrom = $('#date-from').val();
          var dateFromObj = Date.parse(dateFrom);

          var dateTo = $('#date-to').val();
          var dateToObj = Date.parse(dateTo);
          var today = new Date;

          if (dateFromObj > dateToObj) {
              alert('End Date must be after Start Date');
              return false;
          }

          if (dateToObj > today) {
              alert('End Date must be in the past');
              return false;
          }

        $('.sub-investor-statement-form').attr('action', '/admin/sub_investors/' + subInvestorId + '/generate_statement')
      });

      var popupDiv = popup(content, null, []);
      $('#date-from').datepicker({ dateFormat: "yy-mm-dd" });
      $('#date-to').datepicker({ dateFormat: "yy-mm-dd" });
      $('body').css('overflow', 'hidden');
      popupDiv.fadeIn('fast');

      $('.filter-select.sub-investments option[value="all"]').attr('data-start-date', minStartDate)
      $('.sub-investments option[value="all"]').attr('data-end-date', maxEndDate)
      setDateRange(minStartDate, maxEndDate);

      $('.filter-select.sub-investments').on('change', function() {
          var option = $('.filter-select.sub-investments option:selected');
          setDateRange(option.data('start-date'), option.data('end-date'));
      })

      function setDateRange(startDate, endDate) {
          var startDate = new Date(startDate)
          var endDate = new Date(endDate)
          $('.date-from #date_select_year').val(startDate.getFullYear());
          $('.date-from #date_select_month').val(startDate.getMonth() + 1);
          $('.date-from #date_select_day').val(startDate.getDate());
          $('.date-to #date_select_year').val(endDate.getFullYear());
          $('.date-to #date_select_month').val(endDate.getMonth() + 1);
          $('.date-to #date_select_day').val(endDate.getDate());
      }

      var defaultInvestSourceNames = ['Innovation Capital Investment Corp.', 'Van Haren Investment Corp.', 'Innovation Capital Investment USA Inc.'];
      $.each(defaultInvestSourceNames, function(index, investmentSourceName) {
          $(".investment-source-wrapper input[data-investment-source-name='" + investmentSourceName + "']").attr('checked', true);
      })

      $(".investment-status-wrapper input[value='active']").attr('checked', true);
      e.preventDefault();
      return false;
    })
  }

  // Sub Investor Retained Statement
  if ($('.sub-investor-retained-statement').length > 0) {
    $(document).on('click', '.sub-investor-retained-statement', function(e){
      var subInvestorId = $('.sub-investor-id').data('id')
      var subInvestments = '<select class="filter-select sub-investments">';

      subInvestments += '<option value="all">All</option>';
      $.each($('.sub-investment-option'), function(i, v) {
          subInvestments += '<option value="' + $(v).data('id') + '">'+ $(v).data('name') +'</option>';
      });
      subInvestments += '</select>'

      var investmentSources = '<div class="investment-source-wrapper"><fieldset class="choices">';

      $.each($('.investment-source'), function(i, v) {
        investmentSources += '<label for="q_investment_source_id_' + $(v).data('id') + '"><input type="checkbox" name="investment_source[]" value="' + $(v).data('id') + '" data-investment-source-name="' + $(v).data('name') + '">' + $(v).data('name') + '</label>'
      });
      investmentSources += '</fieldset></div>';

      var investmentStatus = `<div class="investment-status-wrapper"><fieldset class="choices">
        <label><input type="checkbox" name="investment_status[]" value="active">ACTIVE</label>
        <label><input type="checkbox" name="investment_status[]" value="archived">ARCHIVED</label>
        <label><input type="checkbox" name="investment_status[]" value="future">FUTURE</label>
        </fieldset></div>`;

      var paymentKind = `<div class="payment-kind-wrapper"><fieldset class="choices">
        <label><input type="checkbox" name="payment_kind[]" value="Accrued" checked>Accrued</label>
        <label><input type="checkbox" name="payment_kind[]" value="Retained" checked>Interest Reserve</label>
        <label><input type="checkbox" name="payment_kind[]" value="Misc" checked>MISC</label>
        </fieldset></div>`;


      var paymentStatus = `<div class="payment-status-wrapper"><fieldset class="choices">
        <label><input type="radio" name="paid" value="true">Paid</label>
        <label><input type="radio" name="paid" value="false" checked>Pending</label>
        </fieldset></div>`;

      var content = $(`
        <form class="sub-investor-statement-form" method="post">
          <fieldset class="inputs">
            <legend><span>Select your sub investment</span></legend>
            <div class="accrued-retained-report-title">
              This report is used to generate a list of Investments and their Pending or Paid Accrued or Interest Reserve amounts.
            </div>
            <ol>
              <input id="sub-investment-id" name="sub_investment_id" type="hidden" />
              <li class="string input optional stringish">${subInvestments}</li>
              
              
              <li>
                <label style="width: 100%;float: none;">DATE RANGE</label>
                <div class="date-from"><input id="date-from" name="date_from" type="text" /></div>
                -
                <div class="date-to"><input id="date-to" name="date_to" type="text" /></div>
              </li>
              <input id="investment-source-id" name="investment_source_id" type="hidden" />
              <li><label style="width: 100%;float: none;">INVESTMENT SOURCE</label></li>
              <li class="string input optional stringish">${investmentSources}</li>
              <li><label style="width: 100%;float: none;">INVESTMENT STATUS </label></li>
              <li>${investmentStatus}</li>
              <li><label style="width: 100%;float: none;">Payment Type </label></li>
              <li>${paymentKind}</li>
              <li><label style="width: 100%;float: none;">Payment Status </label></li>
              <li>${paymentStatus}</li>
              <li>
                <label style="width: 100%;float: none;">
                  <input name="email" class="email" type="checkbox" value="true" /> Send sub-investor statement
                </label>
              </li>
              <fieldset class="actions" style="padding-left: 10px;margin:0;">
                <ol>
                  <li class="action input_action "><input name="commit" type="submit" value="Generate Report" class="make-payment"></li>
                  <li class="cancel"><a href="javascript:void(0)" class="close-popup">Cancel</a></li>
                </ol>
              </fieldset>
            </ol>
          </fieldset>
        </form>`);
      content.submit(function() {
        $('.sub-investor-statement-form #sub-investment-id').val($('.sub-investor-statement-form .sub-investments option:selected').val())
        $('.sub-investor-statement-form #investment-source-id').val($('.sub-investor-statement-form .investment-sources option:selected').val())

        var dateFrom = $('#date-from').val();
        var dateFromObj = Date.parse(dateFrom);

        var dateTo = $('#date-to').val();
        var dateToObj = Date.parse(dateTo);

        var today = new Date;

        if (dateFromObj > today) {
            alert('Start Date must be in the past');
            return false;
        }

        if (dateFromObj > dateToObj) {
            alert('End Date must be after Start Date');
            return false;
        }

        if ($('[name="payment_kind[]"]:checked').length == 0) {
          alert('You should select at least one payment type!');
          return false;
        } else {
          $('.sub-investor-statement-form').attr('action', '/admin/sub_investors/' + subInvestorId + '/generate_accrued_retailed_report');
        }
      });

      var popupDiv = popup(content, null, []);
      $('body').css('overflow', 'hidden');
      $('#date-from').datepicker({ dateFormat: "yy-mm-dd" });
      $('#date-to').datepicker({ dateFormat: "yy-mm-dd" });
      popupDiv.fadeIn('fast');

      // set default values
      $(".date-from #date_select_year option[value='2007']").attr('selected', true);
      $(".date-from #date_select_month option[value='1']").attr('selected', true);
      $(".date-from #date_select_day option[value='1']").attr('selected', true);
      var d = new Date();
      var day = d.getDate();
      var month = d.getMonth() + 1;
      var year = d.getFullYear();
      $(".date-to #date_select_year option[value='" + year + "']").attr('selected', true);
      $(".date-to #date_select_month option[value='" + month + "']").attr('selected', true);
      $(".date-to #date_select_day option[value='" + day + "']").attr('selected', true);

      var defaultInvestSourceNames = ['Innovation Capital Investment Corp.', 'Van Haren Investment Corp.', 'Innovation Capital Investment USA Inc.'];
      $.each(defaultInvestSourceNames, function(index, investmentSourceName) {
          $(".investment-source-wrapper input[data-investment-source-name='" + investmentSourceName + "']").attr('checked', true);
      })

      $(".investment-status-wrapper input[value='active']").attr('checked', true);

      e.preventDefault();
      return false;
    })
  }

  if($('body.index.admin_user_payments').length > 0) {
    $('.download_links a:last').addClass('pdf');
    var emailLink = $('<a href="#" class="email">Email</a>');
    $('.download_links').append('&nbsp;').append(emailLink);

    emailLink.on('click', (function(){
      if($('.index_table tbody input:checked').length > 0) {
          alert('Please do not check any payment');
          return false;
      }

      var checkNos = [];
      $.each($('.index_table tbody .amount'), function(index, amount) {
          var checkNo = $(amount).next().text().trim();
          checkNos.push(checkNo);
      });
      if($.unique(checkNos).length > 1) {
          alert('The payments have different Check Numbers');
          return false;
      }

      var paymentIds = [];
      // send payments
      $.each($('.index_table tbody .collection_selection'), function(index, slection) {
          paymentIds.push($(slection).val());
      });
      if(paymentIds.length == 0) {
          return false;
      }


      var today = new Date();
      var dd = String(today.getDate()).padStart(2, '0');
      var mm = String(today.getMonth() + 1).padStart(2, '0');
      var yyyy = today.getFullYear();
      today = mm + '/' + dd + '/' + yyyy;

      var content = $(`
        <form class="sub-investor-statement-form" method="post">
          <fieldset class="inputs">
            <legend><span>Send Email</span></legend>
            <ol>
              <li>
                <label style="width: 100%;float: none;">DATE:</label>
                <div class="date-from">${today}</div>
              </li>
              <li>
                <label style="width: 100%;float: none;">Receiver:</label>
                <div class="date-from">
                  ${$('#page_title').html().replace("Payments", "").trim()}
                </div>
              </li>
              <fieldset class="actions" style="padding-left: 10px;margin:0;">
                <ol>
                  <li class="action input_action "><input name="commit" type="submit" value="Send Email" class="send-email"></li>
                  <li class="cancel"><a href="javascript:void(0)" class="close-popup">Cancel</a></li>
                </ol>
              </fieldset>
            </ol>
          </fieldset>
        </form>`);

      content.submit(function() {
          var notice = $('<span class="color:#03c;">&nbsp;Mail is been sending...</span>');
          $('.download_links').append(notice);
          $.post('/admin/payments/send_mail', {collection_selection: paymentIds}, function() {
              notice.html("&nbsp;Mail has been sent");
          });
      });

      var popupDiv = popup(content, null, []);
      $('body').css('overflow', 'hidden');
      popupDiv.fadeIn('fast');

      emailLink.css('text-decoration', 'none').css('cursor', 'default').css('color', '#eee').off('click').click(function(){return false;});
      return false;
    }));
  }


  if ($('#upload-signed-acknowledgment').length > 0) {
    var subInvestorId = $('.sub-investor-id').data('id')
    var upload_form_str = `
      <form method="post" enctype="multipart/form-data" action="/admin/sub_investors/${subInvestorId}/upload_signed_acknowledgment">
        <fieldset class="inputs">
          <legend><span>Upload Signed Acknowledgment</span></legend>
          <label style="width:30%;">Select File</label>
          <input type="file" name="signed_acknowledgment" accept="application/pdf">
          <fieldset class="actions" style="padding-left: 10px;margin:0;">
            <ol>
              <li class="action input_action ">
                <input name="upload" type="submit" value="Upload" class="upload-acknowledgment">
              </li>
              <li class="cancel"><a href="javascript:void(0)" class="close-popup">Cancel</a></li>
            </ol>
          </fieldset>
        </fieldset>
      </form>`;
    var upload_form_html = $(upload_form_str);
    popup(upload_form_html, $('#upload-signed-acknowledgment'), [['width', '40%'], ['left', '30%']]);

    $('.upload-acknowledgment').click(function() {
      var url = `/admin/sub_investors/${subInvestorId}/upload_signed_acknowledgment`;
      upload_form_html.attr('action', url);
      upload_form_html.submit();
      return false;
    });
  }

  if ($('.acknowledgment a').length > 0) {
    $action_items = $('.action_item').detach();

    $left_container = $('<div class="left-items"></div>');
    $right_container = $('<div class="right-items"></div>');

    $left_container.append($action_items);
    $('.action_items').append($left_container);
    
    $acknowledgment_items = $('.acknowledgment').detach();
    $right_container.append($acknowledgment_items);
    $('.action_items').append($right_container);
  }
});