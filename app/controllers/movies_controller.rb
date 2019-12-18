class MoviesController < ApplicationController
  before_action :require_movie, only: [:show]

  def create
    movie = Movie.new(movie_params)
    movie.inventory = 10

    if movie.save
      render json: movie.as_json, status: :ok
      return
    else
      render json: {errors: movie.errors.messages}, status: :not_acceptable
      return
    end
  end

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

  private

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end

  def movie_params
    params.permit(:title, :overview, :release_date, :image_url, :external_id)
  end
end
