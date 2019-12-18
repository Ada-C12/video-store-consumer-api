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

  def create(params)
    p params["id"]
    @movie = Movie.new(
      title: params["title"],
      overview: params["overview"],
      release_date: params["release_date"],
      image_url: MovieWrapper.construct_image_url(params["poster_path"]),
      external_id: params["id"],
      inventory: params["inventory"]
    )
    puts @movie
  end

    if @movie.save
      render json: @movie, status: :ok
      # redirect_to root_path
      return
    else
      render json: { errors: { title: ["Failed to save to rental library"] } }, status: :bad_request
      return
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
