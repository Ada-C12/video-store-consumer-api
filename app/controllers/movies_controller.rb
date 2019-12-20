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
    movie = Movie.new(movie_params)

    movie_check = Movie.find_by(title: movie.title)

    if movie_check 
      render status: :ok, json: {failure: "#{movie_params[:title]} is already in your rental library"}
    elsif movie.save
      render status: :ok, json: {success: "you have successfully added #{movie_params[:title]} to your rental library"}
    else
      render status: :bad_request, json: {errors: movie.errors.messages}
    end 
  end 

  private

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end

  def movie_params
    return params.permit(:title, :overview, :release_date, :inventory, :image_url, :external_id)
  end 
end
