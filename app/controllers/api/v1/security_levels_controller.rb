class Api::V1::SecurityLevelsController < ApplicationController
  before_action :set_api_v1_security_level, only: [:show, :update, :destroy]

  # GET /api/v1/security_levels
  def index
    @api_v1_security_levels = Api::V1::SecurityLevel.all

    render json: @api_v1_security_levels
  end

  # GET /api/v1/security_levels/1
  def show
    render json: @api_v1_security_level
  end

  # POST /api/v1/security_levels
  def create
    @api_v1_security_level = Api::V1::SecurityLevel.new(api_v1_security_level_params)

    if @api_v1_security_level.save
      render json: @api_v1_security_level, status: :created, location: @api_v1_security_level
    else
      render json: @api_v1_security_level.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/security_levels/1
  def update
    if @api_v1_security_level.update(api_v1_security_level_params)
      render json: @api_v1_security_level
    else
      render json: @api_v1_security_level.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/security_levels/1
  def destroy
    @api_v1_security_level.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_security_level
      @api_v1_security_level = Api::V1::SecurityLevel.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def api_v1_security_level_params
      params.fetch(:api_v1_security_level, {})
    end
end
