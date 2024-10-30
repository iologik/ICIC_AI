# frozen_string_literal: true

namespace :investment do
  task ori_amount: :environment do
    Investment.all.each do |investment|
      investment.ori_amount = investment.amount
      investment.save
    end
  end

  task source: :environment do
    # crate ICIC and Imor source is not exist
    icic = InvestmentSource.where(name: 'ICIC').first_or_create
    # imor
    unless InvestmentSource.find_by_name('Imor')
      imore = InvestmentSource.find_by_name('Imore')
      if imore
        imore.update_attribute :name, 'Imor'
      else
        InvestmentSource.create(name: 'Imor')
      end
    end
    # ICIC by default
    Investment.all.each do |investment|
      unless investment.investment_source
        investment.investment_source = icic
        investment.save
      end
    end
  end
end
