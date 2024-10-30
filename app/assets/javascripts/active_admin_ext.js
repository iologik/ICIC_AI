// popup method
var popup = function(contentElement, openPopupBtn, styles) {
    var popupDiv = $("<div class='popup-background popup-modal' style='display:none;'></div>");
    var popupContainer = $("<div class='popup-box popup-modal-content'></div>");
    for(var i in styles) {
        popupContainer.css(styles[i][0], styles[i][1]);
    }

    contentElement.appendTo(popupContainer);
    popupContainer.appendTo(popupDiv);
    popupDiv.appendTo('body');

    if(openPopupBtn) {
        openPopupBtn.click(function(){
            $('body').css('overflow', 'hidden');
            popupDiv.fadeIn('fast');
            return false;
        });
    }
    return popupDiv;
}
window.popup = popup;// TODO

// common js
Number.prototype.formatMoney = function(c, d, t){
    var n = this,
        c = isNaN(c = Math.abs(c)) ? 2 : c,
        d = d == undefined ? "." : d,
        t = t == undefined ? "," : t,
        s = n < 0 ? "-" : "",
        i = parseInt(n = Math.abs(+n || 0).toFixed(c)) + "",
        j = (j = i.length) > 3 ? j % 3 : 0;
    return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
};

$(function () {
    // close popup
    function closePopup() {
        $('.popup-background').fadeOut('fast');
        $('body').css('overflow', 'visible');
    }
    $('body').on('click', '.close-popup', function () {
        if(confirm('Are you sure to cancel?')) {
            closePopup();
        }
    });
    $('body').on('click', '.close-popup-no-confirm', function () {
        closePopup();
    });

    // date select with name date
    var dateSelect = function(date = undefined) {
        var today = new Date();
        var until = today.getFullYear() + 10;
        var cur_year, cur_month, cur_date;
        cur_year = cur_month = cur_date = undefined;
        if (date) {
            var date_str = date.toISOString().split('T')[0];

            cur_year  = date_str.slice(0, 4);
            cur_month = date_str.slice(5, 7);
            cur_date  = date_str.slice(8, 10);
        }
        var yearSelect = '<option value=""></option>';
        for (var i = 2007; i <= until; i++) {
            if (cur_year && cur_year == i) {
                yearSelect += `<option value="${i}" selected>${i}</option>`
            }
            else {
                yearSelect += `<option value="${i}">${i}</option>`
            }
        }
        var monthSelect = '<option value=""></option>';
        for (i = 1; i < 13; i++) {
            _i = i.toString().padStart(2, '0');
            if (cur_month == _i) {
                monthSelect += `<option value="${_i}" selected>${_i}</option>`;
            }
            else {
                monthSelect += `<option value="${_i}">${_i}</option>`;
            }
        }
        var dateSelect = '<option value=""></option>';
        for (i = 1; i < 32; i++) {
            _i = i.toString().padStart(2, '0');
            if (cur_date == _i) {
                dateSelect += `<option value="${_i}" selected>${_i}</option>`;
            }
            else {
                dateSelect += `<option value="${_i}">${_i}</option>`;
            }
        }
        var dom_str = `
          <ol class="fragments-group">
            <li class="fragment" style="float: left;padding: 0;margin: 0 0.5em 0 0;">
              <label for="date_1i" style="display: none;">Year</label>
              <select name="date(1i)" style="width: auto;" id="date_select_year">${yearSelect}</select>
            </li>
            <li class="fragment" style="float: left;padding: 0;margin: 0 0.5em 0 0;">
              <label for="date_2i" style="display: none;">Month</label>
              <select name="date(2i)" style="width: auto;" id="date_select_month">${monthSelect}</select>
            </li>
            <li class="fragment" style="float: left;padding: 0;margin: 0 0.5em 0 0;">
              <label for="date_3i" style="display: none;">Day</label>
              <select name="date(3i)" style="width: auto;" id="date_select_day">${dateSelect}</select>
            </li>
            <li class="fragment" style="padding: 0;clear: both;"></li>
          </ol>`;
        return dom_str;
    }

    // download links
    $('.download_links a').attr('target', '_blank');

    // dashboard background
    $('body.admin_dashboard').css('background-color', '#eee');

    // investment effect account

    var investment_field = $('#sub_investment_investment_id');

    if (investment_field.length != 0) {
        var imor_investment_ids = investment_field.data('imor-investment-ids').split(',');

        // var displayHideAccount = function (investment_id) {
        //     if (imor_investment_ids.indexOf(investment_id) != -1) {
        //         $('#sub_investment_account_input').show();
        //     } else {
        //         $('#sub_investment_account_input').hide();
        //     }
        // }

        // displayHideAccount(investment_field.val());

        // investment_field.change(function () {
        //     displayHideAccount($(this).val());
        // });
    }

    // total info on sub-investor page, imor investments
    if($('#sub_investor_imor_investments').length > 0) {
        var panel = $('#sub_investor_imor_investments');

        function imorTotal(totalContainer, panel) {
          if (panel.find('tbody tr:visible').length == 0) {
            return;
          }

          var amount_total = totalContainer.data('amount-total');
          var per_annum_average = totalContainer.data('per-annum-average');
          var referrand_percent_average = totalContainer.data('referrand-percent');
          var accrued_per_annum_average = totalContainer.data('accrued-per-annum-average');
          var current_accrued_total = totalContainer.data('current-accrued-total');
          var retained_per_annum_average = totalContainer.data('retained-per-annum-average');
          var current_retained_total = totalContainer.data('current-retained-total');

          panel.find('tbody').append(`<tr style="color:#000;" class="total-info-tr">
              <td>&nbsp;</td>
              <td style="text-align:right;color:rgb(50, 53, 55);">Total:</td>
              <td class="total-td">${amount_total}</td>
              <td>&nbsp;</td>
              <td class="total-td">${per_annum_average}</td>
              <td class="total-td">${referrand_percent_average}</td>
              <td class="total-td">${accrued_per_annum_average}</td>
              <td class="total-td">${current_accrued_total}</td>
              <td class="total-td">${retained_per_annum_average}</td>
              <td class="total-td">${current_retained_total}</td>
              <td>&nbsp;</td></tr>`);
        }

        function imorSubTotal(panel) {
            var currentId = null;
            var amount = 0;
            var perAnnum = 0;
            var referrandPercent = 0;
            var accruedPerAnnum = 0;
            var retainedPerAnnum = 0;
            var currentAnnum = 0;
            var count = 0;
            var trs = panel.find('tbody tr:visible');
            var trCount = trs.length;
            $.each(panel.find('tbody tr:visible'), function(i, tr) {
                var accountLink = $(tr).find('.account a');
                var id = accountLink.data('id');
                if(id) {
                    var tempAmount = Number(accountLink.data('amount'));
                    var tempPerAnnum = Number(accountLink.data('per-annum'));
                    var tempReferrandPercent = Number(accountLink.data('referrand-percent'));
                    var tempAccruedPerAnnum = Number(accountLink.data('accrued-per-annum'));
                    var tempCurrentAccrued = Number(accountLink.data('current-accrued'));
                    var tempRetainedPerAnnum = Number(accountLink.data('retained-per-annum'));
                    var tempCurrentRetained = Number(accountLink.data('current-retained'));

                    if(id == currentId) {
                        amount += tempAmount;
                        perAnnum += (tempPerAnnum * tempAmount);
                        referrandPercent += tempReferrandPercent;
                        accruedPerAnnum += (tempAccruedPerAnnum * tempAmount);
                        currentAnnum += tempCurrentAccrued;
                        retainedPerAnnum += (tempRetainedPerAnnum * tempAmount);
                        currentAnnum += tempCurrentRetained;
                        count += 1;
                    } else {
                        addImorSubTotal(accountLink, currentId, amount, perAnnum/amount, referrandPercent/count, accruedPerAnnum/amount, retainedPerAnnum/amount, currentAnnum);
                        currentId = id;
                        amount = tempAmount;
                        perAnnum = (tempPerAnnum * tempAmount);
                        referrandPercent = tempReferrandPercent;
                        accruedPerAnnum = (tempAccruedPerAnnum * tempAmount);
                        currentAnnum = tempCurrentAccrued;
                        retainedPerAnnum = (tempRetainedPerAnnum * tempAmount);
                        currentAnnum = tempCurrentRetained;
                        count = 1;
                    }
                    if(i == (trCount - 1)) {
                        addImorSubTotalAfter(accountLink, currentId, amount, perAnnum/amount, referrandPercent/count, accruedPerAnnum/amount, retainedPerAnnum/amount, currentAnnum);
                    }
                }
            });
        }

        function imorSubTotalInfo(amount, perAnnum, referrandPercent, accruedPerAnnum, retainedPerAnnum, currentAnnum) {
            return `<tr style="color:#000;" class="total-info-tr"><td></td>
                <td style="text-align:right;color:rgb(50, 53, 55);">Sub-Total:</td>
                <td class="total-td">$${amount.formatMoney()}</td>
                <td></td>
                <td class="total-td">${perAnnum.formatMoney()}%</td>
                <td class="total-td">${referrandPercent.formatMoney()}%</td>
                <td class="total-td">${accruedPerAnnum.formatMoney()}%</td>
                <td class="total-td">${retainedPerAnnum.formatMoney()}%</td>
                <td class="total-td">$${currentAnnum.formatMoney()}</td>
                <td></td></tr>`;
        }

        function addImorSubTotal(accountLink, currentId, amount, perAnnum, referrandPercent, accruedPerAnnum, retainedPerAnnum, currentAnnum) {
            if(currentId) {
                accountLink.closest('tr').before(imorSubTotalInfo(amount, perAnnum, referrandPercent, accruedPerAnnum, retainedPerAnnum, currentAnnum));
            }
        }

        function addImorSubTotalAfter(accountLink, currentId, amount, perAnnum, referrandPercent, accruedPerAnnum, retainedPerAnnum, currentAnnum) {
            if(currentId) {
                accountLink.closest('tr').after(imorSubTotalInfo(amount, perAnnum, referrandPercent, accruedPerAnnum, retainedPerAnnum, currentAnnum));
            }
        }

        function makePanelInfoImor(ele = null, _state = null) {
            var state = _state ? _state : $('.filter-box.imor').find('.filter-link.selected').data('state');
            var panel = $('#sub_investor_imor_investments');
            var currency = $('.filter-box').find('.currency:checked').val();
            var investmentSource = []
            $.each($('.filter-box').find('[name="investment_source[]"]:checked'), function(i, source){
              investmentSource.push(parseInt($(source).val()))
            });

            if(ele) {
                ele.closest('.filter-box').find('.selected').removeClass('selected');
                ele.addClass('selected');
            }

            var investmentSource = $('.filter-box').find('.investment-sources option:selected').val();

            $.each(panel.find('table tbody tr'), function(i, tr) {
                var trLink = $(tr).find('td.col-name a');
                var trCurrency = trLink.data('currency');
                var trState = trLink.data('state');
                var trInvestmentSource = trLink.data('investment-source');

                if(state != 'all' && state != trState) {
                    $(tr).addClass('must-hide');
                } else if(currency != 'all' && currency != trCurrency) {
                    $(tr).addClass('must-hide');
                } else if (investmentSource != 'all' && investmentSource != trInvestmentSource) {
                    $(tr).addClass('must-hide');
                } else {
                    $(tr).removeClass('must-hide');
                }
            });
            panel.find('tbody tr.total-info-tr').remove();
            imorSubTotal(panel);
            imorTotal(panel.find('.'+state+'-total'), panel);
        }

        function allPanelInfoImor(ele) {
            makePanelInfoImor(ele, 'all');
        }

        function activePanelInfoImor(ele) {
            makePanelInfoImor(ele, 'active');
        }

        function archivedPanelInfoImor(ele) {
            makePanelInfoImor(ele, 'archived');
        }

        var panel = $('#sub_investor_imor_investments');
        var filterBox = $('<div class="filter-box imor"></div>');
        if(panel.find('.active-total').length > 0 && panel.find('.archived-total').length > 0) {
            filterBox.append("<label class='filter-label'>Filters:</label>");

            var activeLink = $("<a href='#' class='filter-link active' data-state='active'>Active</a>");
            activeLink.click(function(){ activePanelInfoImor($(this));return false; });
            filterBox.append(activeLink);

            var archivedLink = $("<a href='#' class='filter-link archived' data-state='archived'>Archived</a>");
            archivedLink.click(function(){ archivedPanelInfoImor($(this));return false; });
            filterBox.append(archivedLink);

            var allLink = $("<a href='#' class='filter-link all' data-state='all'>All</a>");
            allLink.click(function(){ allPanelInfoImor($(this));return false; });
            filterBox.append(allLink);

            panel.before(filterBox);
            filterBox.find('.active').addClass('selected')
        }
        if(panel.find('.active-total').length > 0) {
            activePanelInfoImor(filterBox.find('.active'));
        } else if(panel.find('.archived-total').length > 0) {
            archivedPanelInfoImor(filterBox.find('.archived'));
        } else if(panel.find('.all-total').length > 0) {
            allPanelInfoImor(filterBox.find('.all'));
        }
    }

    // submit button text for sub_investor(admin_User)
    if($("#sub_investor_submit_action input[type='submit']").length > 0) {
        var button = $("#sub_investor_submit_action input[type='submit']");
        button.val(button.val().replace('Admin user', 'Sub Investor'));
    }

    // error message position
    if($('p.inline-errors').length > 0) {
        $.each($('p.inline-errors'), function(i, v) {
            $(v).css('left', $(v).closest('li.error').width());
        });
    }

    // description or private note for investment or sub-investment
    function descriptionPrivateNote($button) {
      var dom_str = `
          <form class="textarea-form" action="${$button.data('form-url')}" method="post">
            <div style="margin:0;padding:0;display:inline"><input name="_method" type="hidden" value="put"></div>
            <fieldset class="inputs">
              <legend><span>Edit ${$button.data('field')}</span></legend>
              <ol>
                <li class="string input optional stringish">
                  <textarea class='tinymce_editor' name='${$button.data('model')}[${$button.data('field')}]' rows='5' style='height: 180px;'>${$button.prev().html()}</textarea>
                </li>
                <fieldset class="actions" style="padding-left: 10px;margin:0;">
                  <ol>
                    <li class="action input_action "><input name="commit" type="submit" value="Save"></li>
                    <li class="cancel"><a href="javascript:void(0)" class="close-popup">Cancel</a></li>
                  </ol>
                </fieldset>
              </ol>
            </fieldset>
          </form>`;
      return $(dom_str);
    }

    $.each(['.edit-investment-description', '.edit-investment-private-note', '.edit-sub-investment-description', '.edit-sub-investment-private-note'], function(i, v) {
        if($(v).length > 0) {
            var button = $(v);
            var content = descriptionPrivateNote(button);
            popup(content, button, [['width', '60%'], ['left', '20%']]);

            tinymce.init({
                selector: "textarea",
                plugins: [
                    "advlist autolink lists link image charmap print preview hr anchor pagebreak",
                    "searchreplace wordcount visualblocks visualchars code fullscreen",
                    "insertdatetime media nonbreaking save table contextmenu directionality",
                    "emoticons template paste textcolor colorpicker textpattern"
                ],
                toolbar1: "insertfile undo redo | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image",
                toolbar2: "print preview media | fontselect fontsizeselect | forecolor backcolor emoticons",
                templates: [
                    {title: 'Test template 1', content: 'Test 1'},
                    {title: 'Test template 2', content: 'Test 2'}
                ],
                file_picker_callback: function(callback, value, meta) {
                    $("#file").click();
                },
                height : "480"
            });
        }
    });

    // payToClientContent popup box
    function payToClientContent() {
      var form_html = `
          <form method="post">
            <fieldset class="inputs">
              <legend><span>Pay to client</span></legend>
              <ol>
                <li class="string input optional stringish">${dateSelect()}
                </li>
                <fieldset class="actions" style="padding-left: 10px;margin:0;">
                  <ol>
                    <li class="action input_action ">
                      <input name="commit" type="submit" value="Send" class="send">
                    </li>
                    <li class="cancel"><a href="javascript:void(0)" class="close-popup">Cancel</a></li>
                  </ol>
                </fieldset>
              </ol>
            </fieldset>
          </form>`;
      return $(form_html);
    }

    // pay_to_client_div
    if($('#pay_to_client_div').length > 0 || $('#index_table_sub_distributions').length > 0) {
      var content = payToClientContent();
      var popupDiv = popup(content, $('.pay-to-client'), []);

      $('.pay-to-client').click(function(){
        var url = $(this).data('url');
        popupDiv.find('form').attr('action', url);
        popupDiv.find('#date_select_year').val($(this).data('year'));
        popupDiv.find('#date_select_month').val($(this).data('month'));
        popupDiv.find('#date_select_day').val($(this).data('day'));
        popupDiv.find('legend span').text("Pay to client #" + $(this).data('id'));
        return false;
      });
    }

    // payment to client, batch action
    if($('#index_table_sub_distributions').length > 0) {
      var content2 = payToClientContent();
      var popupDiv2 = popup(content2, $('.batch_action'), []);
      popupDiv2.find('form').attr('onsubmit', 'return false');
      $('#collection_selection').find('#batch_action').val('send');

      $('.batch_action').click(function(){
        var date = $('.collection_selection:checked:first').closest('tr').find('.id div');
        popupDiv2.find('#date_select_year').val(date.data('year'));
        popupDiv2.find('#date_select_month').val(date.data('month'));
        popupDiv2.find('#date_select_day').val(date.data('day'));
      });

      popupDiv2.find('.send').click(function(){
        $('#collection_selection').append('<input name="date(1i)" type="hidden" value="'+ popupDiv2.find('#date_select_year').val() +'" />');
        $('#collection_selection').append('<input name="date(2i)" type="hidden" value="'+ popupDiv2.find('#date_select_month').val() +'" />');
        $('#collection_selection').append('<input name="date(3i)" type="hidden" value="'+ popupDiv2.find('#date_select_day').val() +'" />');
        $('#collection_selection').submit();
      });
    }

    // display/hide exchange_rate
    if($('#sub_investment_exchange_rate').length > 0) {

        var investmentField = $('#sub_investment_investment_id');
        var currencies = investmentField.data('investment-currencies');

        var toggleExchangeRate = function() {
            var selectedInvestmentId = $('#sub_investment_investment_id').val();
            var investmentCurrency = currencies[selectedInvestmentId];

            if($('#sub_investment_currency_usd')[0].checked) {
                var subInvestmentCurrency = 'USD';
            } else {
                var subInvestmentCurrency = 'CAD';
            }

            var exchangeRate = $('#sub_investment_exchange_rate');
            if(investmentCurrency == subInvestmentCurrency) {
                exchangeRate.closest('li').hide();
            } else {
                exchangeRate.closest('li').show();
            }
        }

        toggleExchangeRate();
        investmentField.change(toggleExchangeRate);
        $('#sub_investment_currency_usd').click(toggleExchangeRate);
        $('#sub_investment_currency_cad').click(toggleExchangeRate);
    }

    // under value
    $.each($('a.has-under-value'), function(index, e) {
        var value = $(e).data('under-value');
        $(e).after('<br><label style="font-weight: bold;font-size: 12px;">'+value+'</label>');
    });
});

//