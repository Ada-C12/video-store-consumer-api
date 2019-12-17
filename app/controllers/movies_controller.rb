class MoviesController < ApplicationController
  before_action :require_movie, only: [:show]
  
  def index
    if params[:query]
      data = MovieWrapper.search(params[:query])
    else
      data = Movie.all
    end
    
    render status: :ok, json: data
  end
  
  def show
    render(
      status: :ok,
      json: @movie.as_json(
        only: [:title, :overview, :release_date, :inventory],
        methods: [:available_inventory]
      )
    )
  end
  
  def create
    init_order_count = 5
    
    if Movie.already_exist?(params[:external_id])
      render json: { railsErrorMsg: "UH OH!!! MOVIE ALREADY EXISTS IN RENTAL LIBRARY." }, status: :bad_request
      
    else
      newMovie = Movie.new( title: params[:title], overview: params[:overview], release_date: params[:release_date], inventory: init_order_count, image_url: params[:image_url], external_id: params[:external_id])
      if !newMovie.save
        puts "UNABLE TO SAVE NEW MOVIE B/C #{newMovie.error.full_messages}"
      end
    end
    
  end
  
  private
  
  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end
end
