# frozen_string_literal: true

class Rent < ApplicationRecord
  include AASM

  belongs_to :user
  belongs_to :car

  aasm column: :status do
  	state :started, initial: true
  	state :finished

  	event :finish do
  	  transitions from: :started, to: :finished
  	end
  end
end
