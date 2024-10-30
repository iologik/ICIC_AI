window.invest = {
    // freeze_thead: function(table){
    //     var thead = table.find('thead');
    //     $.each(thead.find('th'), function(index, th){
    //         $(th).css('width', $(th).width());
    //     });

    //     $(window).on('scroll', function (e) {
    //         if ($(document).scrollTop() > 40) {
    //             thead.css('position', 'fixed').css('top', '117px');
    //         } else {
    //             thead.css('position', 'static');
    //         }
    //     });
    // },
    displayErrorPopup: function() {
        if($('.flash.flash_alert').length > 0) {
            var text = $('.flash.flash_alert').text();
            var popup = '<div class="alert alert-danger" role="alert">' +
                            text +
                        '<span class="dialog-close">x</span>'
                        '</div>';
            $('body').append(popup);
        }
    }
}

$(function(){
    // relevant users
    var relevantUsers = $('#relevant_user');
    if(relevantUsers.length > 0) {
        var ids = (relevantUsers.data('ids') || "").toString().split(',');
        var names = (relevantUsers.data('names') || "").toString().split(',');

        if(ids.length > 0 && ids[0] != "") { // "".split(",") = [""]
            $.each(ids, function(index, value){
                $('#current_user_profile').after("<li><a href='/login_as/" + value + "'>" + names[index] + "</a></li>");
            });
        }
    }

    // admin flag
    var admin_flag = $('#admin_flag');
    if(admin_flag.length > 0) {
        if(admin_flag.text() == 'false') {
          $('body').addClass('sub-investor');
        }
    }

    //
    var admin_link = $('.breadcrumb a[href="/admin"]');
    if(admin_link.length > 0) {
        admin_link.text('dashboard');
    }

    // display error popup
    window.invest.displayErrorPopup();
    // close error message
    $('body').on('click', '.dialog-close', function() {
        $(this).closest('.alert.alert-danger').hide();
    });

    // batch ation for future payments on sub-investment/loan show page
    if($('.batch-action-form').length > 0) {
        var form = $('.batch-action-form');
        var batchActionButton = form.find('.dropdown_menu_button');
        // tr checkbox, select/unselect all, and enable/disable batch actions button
        form.find('th .collection_selection').change(function(){
            if(this.checked) {
                batchActionButton.removeClass('disabled');
                form.find('td .collection_selection').prop('checked', true);
            } else {
                batchActionButton.addClass('disabled');
                form.find('td .collection_selection').prop('checked', false);
            }
        });
        // td checkbox, enable/disable batch actions button
        form.find('td .collection_selection').change(function() {
            if(this.checked) {
                batchActionButton.removeClass('disabled');
            } else {
                if(form.find('td .collection_selection:checked').length == 0) {
                    batchActionButton.addClass('disabled');
                }
            }
        });
        // batch actions
        var actionSelector = $('#batch_actions_selector');
        actionSelector.find('.batch_action').click(function(){
            var execAction = true;
            if($(this).data('confirm-message')) {
                execAction = false;
                if(confirm($(this).data('confirm-message'))) {
                    execAction = true;
                }
            }
            if(execAction) {
                $('#batch_action').val($(this).data('action'));
                form.submit();
            }
        });
    }

    // Convert All Separated Date Select to Datepicker
    if ($('li.date_select').length > 0) {
        $('li.date_select').each(function(index){
            // Take interest period number
            const id_str = $(this).attr('id');

            // Take label element
            const label_element = $(this).find('fieldset legend label').prop('outerHTML');

            // Take date data
            const year  = $(this).find('fieldset ol.fragments-group li:first-child select').val();
            const month = $(this).find('fieldset ol.fragments-group li:nth-child(2) select').val();
            const date  = $(this).find('fieldset ol.fragments-group li:nth-child(3) select').val();

            // Replace Html Data
            const input_id   = id_str.replace('_input', '');
            const input_name = $(this).find('fieldset ol.fragments-group li:first-child select').attr('name').replace('(1i)', '');
            $(this).html(`
                ${label_element}
                <input id="${input_id}" type="text" name="${input_name}">
            `);
            const class_val = $(`body #${input_id}`).attr('class');
            if ($(`body #${input_id}`).length > 0 && !(class_val && class_val.includes('hasDatepicker'))) {
                $(`body #${input_id}`).datepicker({ dateFormat: "yy-mm-dd" });
                if (year && month && date) {
                    $(`body #${input_id}`).datepicker('setDate', `${year}-${month}-${date}`);
                }
            }
        });
    }
});