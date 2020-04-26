class ListingsController < ApplicationController
  before_action :set_listing, only: [:show, :edit, :update, :destroy]

  # GET /listings
  # GET /listings.json
  def index
    if user_signed_in?
      @listing = Listing.first

      @output = @listing.get_data.sort
    end
  end

  def add
    sym = params['new_sym']["sym"].split(/\,\s?/).map(&:upcase)
    @listing = Listing.first
    existing = @listing.symbols.split(",").sort
    new_set = existing
    sym.each { |s| new_set = new_set + [s] }
    new_set = new_set.flatten.uniq.sort
    unless existing == new_set
      @listing.update(symbols: new_set.join(","))
      @output = @listing.get_data.sort

      respond_to do |format|
        format.js { render 'update' }
      end
    end
  end

  def remove
    sym = [params['sym']]
    @listing = Listing.first
    new_set = (@listing.symbols.split(",") - sym).join(",")
    @listing.update(symbols: new_set)
    @output = @listing.get_data.sort

    respond_to do |format|
      format.js { render 'update' }
    end
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
    # Use callbacks to share common setup or constraints between actions.
    def set_listing
      @listing = Listing.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def listing_params
      params.fetch(:listing, {})
    end
end
