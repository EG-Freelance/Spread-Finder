class ListingsController < ApplicationController
  before_action :set_listing, only: [:show, :edit, :update, :destroy]
  before_action :set_spreads, only: [:charts, :tables]

  # GET /listings
  # GET /listings.json
  def index
    if user_signed_in?
      @listing = Listing.first

      @syms = @listing.symbols.split(",")
    end
  end

  def add
    @syms = params['new_sym']["sym"].split(/\,\s?/).map(&:upcase)
    @listing = Listing.first
    existing = @listing.symbols.split(",").sort
    new_set = existing
    @syms.each { |s| new_set = new_set + [s] }
    new_set = new_set.flatten.uniq.sort
    unless existing == new_set
      @listing.update(symbols: new_set.join(","))

      respond_to do |format|
        format.js { render 'update' }
      end
    end
  end

  def remove
    @sym = [params['sym']]
    @listing = Listing.first
    new_set = (@listing.symbols.split(",") - @sym).join(",")
    @listing.update(symbols: new_set)

    respond_to do |format|
      format.js { render 'remove' }
    end
  end

  def charts
    @b_sym = params['sym']
    @b_yw = params['yw']

    if @spreads.find { |s| s.sym == @b_sym && s.year_week == @b_yw }.nil?
      # if spread doesn't exist, default to first spread for that sym
      proxy = @spreads.find { |s| s.sym == @b_sym }
      if !proxy.nil?
        @b_yw = proxy.year_week
      else
        # if spreads for that sym also don't exist, default to first spread
        @b_sym = @spreads.first.sym
        @b_yw = @spreads.first.year_week
      end
    end
  end

  def tables
  end
  # GET /listings/1
  # GET /listings/1.json
  def show
  end

  # GET /listings/new
  def new
    @listing = Listing.new
  end

  # GET /listings/1/edit
  def edit
  end

  # POST /listings
  # POST /listings.json
  def create
    @listing = Listing.new(listing_params)

    respond_to do |format|
      if @listing.save
        format.html { redirect_to @listing, notice: 'Listing was successfully created.' }
        format.json { render :show, status: :created, location: @listing }
      else
        format.html { render :new }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /listings/1
  # PATCH/PUT /listings/1.json
  def update
    respond_to do |format|
      if @listing.update(listing_params)
        format.html { redirect_to @listing, notice: 'Listing was successfully updated.' }
        format.json { render :show, status: :ok, location: @listing }
      else
        format.html { render :edit }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_data
    @sym = params['sym']
    @data = Listing.first.get_data_individ(@sym)

    respond_to do |format|
      format.js { render 'update_data' }
    end
  end

  # DELETE /listings/1
  # DELETE /listings/1.json
  def destroy
    @listing.destroy
    respond_to do |format|
      format.html { redirect_to listings_url, notice: 'Listing was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_spreads
      @spreads = Spread.all.sort_by { |s| [s.year_week, s.sym] }
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_listing
      @listing = Listing.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def listing_params
      params.fetch(:listing, {})
    end
end
