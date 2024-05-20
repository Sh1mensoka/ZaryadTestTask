# frozen_string_literal: true

class RentsController < ApplicationController
  before_action :rent_available?, only: %i[start_rental]
  before_action :rent_can_be_finished?, only: %i[end_rental]

  def start_rental
  	result, status = Interactors::Rents::Start.call(user_id: current_devise_api_user.id, car_id: permitted_params[:car_id])

    render_json_response(result, status)
  end

  def end_rental
  	result, status = Interactors::Rents::Finish.call(rent_id: permitted_params[:id])

    render_json_response(result, status)
  end

  private

  def permitted_params
    params.require(:rent).permit(:id, :car_id)
  end

  def rent_available?
    render json: {
      message: "You can't rent a car while you have active rent",
      status: 400
    },
    status: :bad_request if current_devise_api_user.has_active_rent?
  end

  def rent_can_be_finished?
    render json: {
      message: "Rent has already been finished or doesn't exist",
      status: 400
    },
    status: :bad_request unless Rent.find_by(id: permitted_params[:id])&.may_finish? || false
  end

  def render_json_response(result, status)
    if result.is_a?(Rent)
      render json: result, include: [:user, :car], status: status
    else
      render json: result, status: status
    end
  end
end
