# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, skip: [:sessions, :passwords, :registrations]

  post 'rents/start_rental', to: 'rents#start_rental'
  post 'rents/end_rental', to: 'rents#end_rental'
end
