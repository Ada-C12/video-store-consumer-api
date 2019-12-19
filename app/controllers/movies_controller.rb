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
    # if title is in db alerady, render json w/ error
    # else
    movie_in_db = Movie.find_by(title: params[:title])
    if movie_in_db
      data = "Movie is already in database"
    else
      new_movie = Movie.new(
        title: params[:title],
        overview: params[:overview],
        release_date: params[:release_date],
        # inventory: params[:inventory], # AAAAH
        image_url: params[:image_url],
        external_id: params[:external_id]
      )
      data = "Movie added!"
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
