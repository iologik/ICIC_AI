$(function(){
    $(document).ready(function(){
        // accrued notification batch js
        if ($('.accrued-notification-batch-check').length > 0) {
            $('.send-notification').click(function () {
                var self = this;
                var classes = $(this).attr('class');
                if (classes.indexOf('ok') != -1 || classes.indexOf('error') != -1 || classes.indexOf('sending') != -1) {
                    return;
                }
                $(self).addClass('sending');
                $(self).text('Sending');
                var subInvestmentId = $(this).data('sub-investment');
                var endDate = $('#accrued-notification-end-date').val();

                $.ajax({
                    type: 'POST',
                    url: '/admin/sub_investments/' + subInvestmentId + '/accrued_notify',
                    data: { date: endDate },
                    success: function(data) {
                        $(self).text('Sent');
                        setTimeout(function() {
                          $(self).text('Batch Send');
                        }, 3000)
                    },
                    error: function(err) {
                        $(self).addClass('error');
                        $(self).text('Error');
                    }
                })
                return false;
            });
            $('.accrued-notification-batch-check').on('click', function() {
                var isChecked = $(this).is(':checked');
                $('.accrued-notification-line-check').prop('checked', isChecked);

                if (isChecked) {
                    $('.accrued-notification-batch-send').addClass('active')
                } else {
                    $('.accrued-notification-batch-send').removeClass('active')
                }
            })

            $('.accrued-notification-line-check').on('click', function() {
                if ($('.accrued-notification-line-check:checked').length > 0) {
                    $('.accrued-notification-batch-send').addClass('active');
                } else {
                    $('.accrued-notification-batch-send').removeClass('active');
                }
            })

            $('.accrued-notification-batch-send').on('click', function() {
                var subInvestmentIds = []

                $.each($('.accrued-notification-line-check:checked'), function(i, notification) {
                    subInvestmentIds.push($(notification).data('sub-investment-id'));
                })

                if (subInvestmentIds.length > 0) {
                    var self = this;
                    var classes = $(this).attr('class');
                    if (classes.indexOf('ok') != -1 || classes.indexOf('error') != -1 || classes.indexOf('sending') != -1) {
                        return;
                    }
                    $(self).addClass('sending');
                    $(self).text('Sending');
                    var endDate = $('#accrued-notification-end-date').val();

                    $.ajax({
                        type: 'POST',
                        url: '/admin/sub_investments/batch_accrued_notify',
                        data: {sub_investment_ids: subInvestmentIds, date: endDate},
                        success: function(data) {
                            $(self).text('Sent');
                            setTimeout(function() {
                              $(self).text('Batch Send');
                            }, 3000);
                        },
                        error: function(err) {
                            $(self).addClass('error');
                            $(self).text('Error');
                        }
                    })

                    return false;
                }
            })
            $('#accrued-notification-end-date').on('change', function() {
                let endDate = $('#accrued-notification-end-date').val();
                window.location.href = '/admin/accrued_notification?end_date=' + endDate;
            })
        }
    });
})