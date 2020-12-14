class Api::V1::PeopleController < ApplicationController
  before_action :set_api_v1_person, only: [:show, :update, :destroy]

  # GET /api/v1/people
  def index
    @api_v1_people = Api::V1::Person.all

    render json: @api_v1_people
  end

  # GET /api/v1/people/1
  def show
    render json: @api_v1_person
  end

  # POST /api/v1/people
  def create
    @api_v1_person = Api::V1::Person.new(api_v1_person_params)

    if @api_v1_person.save
      render json: @api_v1_person, status: :created, location: @api_v1_person
    else
      render json: @api_v1_person.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/people/1
  def update
    if @api_v1_person.update(api_v1_person_params)
      render json: @api_v1_person
    else
      render json: @api_v1_person.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/people/1
  def destroy
    @api_v1_person.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_person
      @api_v1_person = Api::V1::Person.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def api_v1_person_params
      params.fetch(:api_v1_person, {})
    end
end
