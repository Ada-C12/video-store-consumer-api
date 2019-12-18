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

  def new
    @movie = Movie.new
  end

  def create
    # @movie = Movie.find_by(title: params[:title])

    # @movie_params = request.body.read
    # puts @movie_params
    @movie = Movie.new
    @movie.title = params[:title]
    @movie.overview = params[:overview]
    @movie.release_date = params[:release_date]
    @movie.image_url = params[:image_url]

    save_success = @movie.save

    puts save_success
  end

  def show
    render(
      status: :ok,
      json: @movie.as_json(
        only: [:title, :overview, :release_date, :inventory],
        methods: [:available_inventory],
      ),
    )
  end

  private

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end
end
