class Api::V1::TeamMembersController < ApplicationController
  before_action :set_api_v1_team_member, only: [:show, :update, :destroy]

  # GET /api/v1/team_members
  def index
    @api_v1_team_members = Api::V1::TeamMember.all

    render json: @api_v1_team_members
  end

  # GET /api/v1/team_members/1
  def show
    render json: @api_v1_team_member
  end

  # POST /api/v1/team_members
  def create
    @api_v1_team_member = Api::V1::TeamMember.new(api_v1_team_member_params)

    if @api_v1_team_member.save
      render json: @api_v1_team_member, status: :created, location: @api_v1_team_member
    else
      render json: @api_v1_team_member.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/team_members/1
  def update
    if @api_v1_team_member.update(api_v1_team_member_params)
      render json: @api_v1_team_member
    else
      render json: @api_v1_team_member.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/team_members/1
  def destroy
    @api_v1_team_member.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_team_member
      @api_v1_team_member = Api::V1::TeamMember.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def api_v1_team_member_params
      params.fetch(:api_v1_team_member, {})
    end
end
