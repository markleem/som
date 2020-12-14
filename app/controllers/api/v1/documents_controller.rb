class Api::V1::DocumentsController < ApplicationController
  before_action :set_api_v1_document, only: [:show, :update, :destroy]

  # GET /api/v1/documents
  def index
    @api_v1_documents = Api::V1::Document.all

    render json: @api_v1_documents
  end

  # GET /api/v1/documents/1
  def show
    render json: @api_v1_document
  end

  # POST /api/v1/documents
  def create
    @api_v1_document = Api::V1::Document.new(api_v1_document_params)

    if @api_v1_document.save
      render json: @api_v1_document, status: :created, location: @api_v1_document
    else
      render json: @api_v1_document.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/documents/1
  def update
    if @api_v1_document.update(api_v1_document_params)
      render json: @api_v1_document
    else
      render json: @api_v1_document.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/documents/1
  def destroy
    @api_v1_document.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_document
      @api_v1_document = Api::V1::Document.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def api_v1_document_params
      params.fetch(:api_v1_document, {})
    end
end
