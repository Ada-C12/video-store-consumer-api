class MoviesController < ApplicationController
  def index
    if params[:query]
      data = MovieWrapper.search(params[:query])
    else
      data = Movie.all
    end

    render status: :ok, json: data
  end

  def show
    title = params[:title]
    @movie = Movie.where("lower(title) LIKE ?", "%#{title.downcase}%").all
    
    if !@movie.empty?
      if @movie.length > 1
        render(
          status: :ok,
          json: @movie.as_json(
            only: [:title, :overview, :release_date, :inventory]
            )
          )
      else
        render(
          status: :ok,
          json: @movie[0].as_json(
            only: [:title, :overview, :release_date, :inventory]
            )
          )
      end
    else
      external_movie = MovieWrapper.search(params[:title])
      if external_movie.empty? 
        render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
      else
        if external_movie.length > 1
          json = external_movie.as_json(only: [:title, :overview, :release_date])
          render(
            status: :ok,
            json: { movie: json, not_in_database: 'true' }
          )
          return
        else
          json = external_movie[0].as_json(only: [:title, :overview, :release_date])
          render(
            status: :ok,
            json: { movie: json, not_in_database: 'true' }
          )
          return
        end
      end
    end
  end

  def create 
    @movie = Movie.new(movie_params)
    @movie.inventory = 1
    movie = Movie.find_by(title: params[:title]) 
    if movie == nil && @movie.save
      render(
        status: :ok,
        json: @movie.as_json(
          only: [:title, :overview, :release_date]
          )
        )
    else 
      render(
        status: :bad_request,
        json: @movie.errors.messages.as_json()
        )
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
    params.permit(:title, :overview, :release_date, :inventory, :image_url)
  end
end
