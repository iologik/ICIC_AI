# frozen_string_literal: true

ActiveAdmin.register InvestmentStatus do
  menu parent: 'Reference Tables'
  permit_params :name
  sidebar('title', only: %i(new edit create update), id: 'blank_space_panel') {}
end
