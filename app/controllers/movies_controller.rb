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
  
  def create 
    if Movie.no_available_movie_count(movie_params[:external_id], movie_params[:image_url])
      render json: {
        message: ["#{movie_params[:title]} quantity increased by 1"], 
        status: :ok
      }
      return 
    end
    
    @movie = Movie.new(movie_params)
    
    if @movie.save
      render json: {movie: {id: @movie.id, title:@movie.title}}, status: :ok
    else
      render json: {errors: @movie.errors.messages},
      status: :bad_request
    end
  end
  
  def show
    render(
      status: :ok,
      json: @movie.as_json(
        only: [:title, :overview],
        methods: [:available_inventory]
      )
    )
  end
  
  private
  
  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end
  
  def movie_params
    return params.require(:movie).permit(:title, :overview, :release_date, :image_url, :external_id)
  end
end
