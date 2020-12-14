class Api::V1::NominationsController < ApplicationController
  before_action :set_api_v1_nomination, only: [:show, :update, :destroy]

  # GET /api/v1/nominations
  def index
    @api_v1_nominations = Api::V1::Nomination.all

    render json: @api_v1_nominations
  end

  # GET /api/v1/nominations/1
  def show
    render json: @api_v1_nomination
  end

  # POST /api/v1/nominations
  def create
    @api_v1_nomination = Api::V1::Nomination.new(api_v1_nomination_params)

    if @api_v1_nomination.save
      render json: @api_v1_nomination, status: :created, location: @api_v1_nomination
    else
      render json: @api_v1_nomination.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/nominations/1
  def update
    if @api_v1_nomination.update(api_v1_nomination_params)
      render json: @api_v1_nomination
    else
      render json: @api_v1_nomination.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/nominations/1
  def destroy
    @api_v1_nomination.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_nomination
      @api_v1_nomination = Api::V1::Nomination.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def api_v1_nomination_params
      params.fetch(:api_v1_nomination, {})
    end
end
