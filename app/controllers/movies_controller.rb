class MoviesController < ApplicationController
  before_action :require_movie, only: [:show]
  
  def index
    if params[:query]
      data = MovieWrapper.search(params[:query])
    else
      data = Movie.all
    end

    if params[:p] || params[:n]
      data = data.paginate(page: params[:p], per_page: params[:n])
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
    new_movie = Movie.new(movie_params)
    
    if new_movie.save
      render(
        status: :ok,
        json: new_movie.as_json(
          only: [:title, :overview, :release_date, :external_id, :image_url]
        )
      )
    else
      render json: {
        ok: false,
        errors: new_movie.errors.messages
        }, status: :bad_request
    end
  end
    
  private
  def movie_params
    return params.permit(:title, :overview, :release_date, :external_id, :image_url)
  end
  
  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end
end
  