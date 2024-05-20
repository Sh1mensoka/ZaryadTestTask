# frozen_string_literal: true

class Car < ApplicationRecord
  include AASM

  has_many :rents
  has_many :users, through: :rents

  aasm column: :status do
  	state :available, initial: true
  	state :in_rent, :unavailable

  	event :start_rent do
  	  transitions from: :available, to: :in_rent
  	end

  	event :finish_rent do
  	  transitions from: :in_rent, to: :available
  	end

  	event :set_unavailable do
      transitions from: [:available, :in_rent], to: :unavailable
  	end

  	event :set_available do
      transitions from: :unavailable, to: :available
  	end
  end
end
