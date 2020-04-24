class QueriesController < ApplicationController
  before_action :set_query, only: [:show, :edit, :update, :destroy]

  # GET /queries
  # GET /queries.json
  def index
    if user_signed_in?
      @query = Query.first

      @output = @query.get_data.sort
    end
  end

  def add
    sym = params['new_sym']["sym"]
    @query = Query.first
    unless @query.symbols.match(/(?:,|\A)#{sym}(?:,|\z)/)
      new_sym = @query.symbols + ",#{sym}"
      @query.update(symbols: new_sym)
      @output = @query.get_data.sort

      respond_to do |format|
        format.js { render 'update' }
      end
    end
  end

  def remove
    sym = params['sym']
    @query = Query.first
    @query.update(symbols: @query.symbols.gsub(/(?:,|\A)#{sym}(?:,|\z)/, ""))
    @output = @query.get_data.sort

    respond_to do |format|
      format.js { render 'update' }
    end
  end
  # GET /queries/1
  # GET /queries/1.json
  def show
  end

  # GET /queries/new
  def new
    @query = Query.new
  end

  # GET /queries/1/edit
  def edit
  end

  # POST /queries
  # POST /queries.json
  def create
    @query = Query.new(query_params)

    respond_to do |format|
      if @query.save
        format.html { redirect_to @query, notice: 'Query was successfully created.' }
        format.json { render :show, status: :created, location: @query }
      else
        format.html { render :new }
        format.json { render json: @query.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /queries/1
  # PATCH/PUT /queries/1.json
  def update
    respond_to do |format|
      if @query.update(query_params)
        format.html { redirect_to @query, notice: 'Query was successfully updated.' }
        format.json { render :show, status: :ok, location: @query }
      else
        format.html { render :edit }
        format.json { render json: @query.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /queries/1
  # DELETE /queries/1.json
  def destroy
    @query.destroy
    respond_to do |format|
      format.html { redirect_to queries_url, notice: 'Query was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_query
      @query = Query.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def query_params
      params.fetch(:query, {})
    end
end
