$(function () {
    $(document).ready(function(){
        if ($('.investment-balance-report').length > 0) {
            $('.investment-balance-report #q_sub_investor_id').on('change', function(){
                var subInvestorId = $('.investment-balance-report #q_sub_investor_id').val();
                $.each($('.investment-balance-report #q_sub_investment_id option'), function(index, option) {
                    var currentOption = $(option);
                    if (!subInvestorId || !currentOption.data('sub-investor-id') || currentOption.data('sub-investor-id') == subInvestorId) {
                        currentOption.removeClass('hidden');
                        return;
                    }
                    currentOption.addClass('hidden')
                })
            })
        }
    });
});