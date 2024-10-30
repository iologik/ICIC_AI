$(function () {
  if ($('.interest-reserve-notification-batch-check').length > 0) {
    $('.send-notification').click(function () {
        var self = this;
        var classes = $(this).attr('class');
        if (classes.indexOf('ok') != -1 || classes.indexOf('error') != -1 || classes.indexOf('sending') != -1) {
            return;
        }
        $(self).addClass('sending');
        $(self).text('Sending');
        var subInvestmentId = $(this).data('sub-investment');
        var endDate = $('#interest-reserve-notification-end-date').val();

        $.ajax({
          type: 'POST',
          url: '/admin/sub_investments/' + subInvestmentId + '/retained_notify',
          data: {date: endDate},
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
    $('.interest-reserve-notification-batch-check').on('click', function() {
      var isChecked = $(this).is(':checked');
      $('.interest-reserve-notification-line-check').prop('checked', isChecked)

      if (isChecked) {
        $('.interest-reserve-notification-batch-send').addClass('active')
      } else {
        $('.interest-reserve-notification-batch-send').removeClass('active')
      }
    })

    $('.interest-reserve-notification-line-check').on('click', function() {
      if ($('.interest-reserve-notification-line-check:checked').length > 0) {
        $('.interest-reserve-notification-batch-send').addClass('active')
      } else {
        $('.interest-reserve-notification-batch-send').removeClass('active')
      }
    })

    $('.interest-reserve-notification-batch-send').on('click', function() {
      var subInvestmentIds = []

      $.each($('.interest-reserve-notification-line-check:checked'), function(i, notification) {
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
        var endDate = $('#interest-reserve-notification-end-date').val();

        $.ajax({
          type: 'POST',
          url: '/admin/sub_investments/batch_retained_notify',
          data: {sub_investment_ids: subInvestmentIds, date: endDate},
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
      }
    })

    $('#interest-reserve-notification-end-date').on('change', function() {
        let endDate = $('#interest-reserve-notification-end-date').val();
        window.location.href = '/admin/interest_reserve_notification?end_date=' + endDate;
    })
  }
})
