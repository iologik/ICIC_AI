$(function(){
  if ($('.admin_t5_report').length > 0) {
    $('.investment-source').on('change', function() {
      updateLink();
    })

    $('.payment-type').on('change', function() {
      updateLink();
    })

    $('#t5-exchange-rate').on('keyup', function() {
      updateCsvLink();
    })

    function updateLink() {
      var investmentSourceType = '';
      $('.investment-source:checked').each(function(i, self) {
        investmentSourceType += "&" + "investment_source_ids[]=" + $(self).val();
      })

      var paymentType = ""
      $('.payment-type:checked').each(function(i, self) {
        paymentType += "&" + "payment_type[]=" + $(self).val();
      })

      window.location.href = window.location.origin + "/admin/t5_report?year=" + $('.year.selected a').html().trim() + investmentSourceType + paymentType
    }

    function updateCsvLink() {
      // get value;
      const exchange_rate = $('#t5-exchange-rate').val();
      const exch_rate_key = 'exchange_rate';

      const ori_link  = $('a.csv').attr('href');
      const [base_link, param_link] = ori_link.split('?');
      const param_strs = param_link.split('&');
      let value_added = false;
      let result_link = `${base_link}?`;
      param_strs.forEach(element => {
        if (!element) return;

        let [key, value] = element.split('=');
        if (key == exch_rate_key) {
          value = exchange_rate;
          value_added = true;
        }
        result_link += `${key}=${value}&`;
      });
      if (value_added == false) {
        result_link += `${exch_rate_key}=${exchange_rate}`
      }
      $('a.csv').attr('href', result_link);
    }
  }
})
