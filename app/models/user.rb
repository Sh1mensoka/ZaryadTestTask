# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable, :api

  has_many :rents
  has_many :cars, through: :rents

  def has_active_rent?
    rents.where(status: 'started').exists?
  end
end
