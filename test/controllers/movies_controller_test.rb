require 'test_helper'

class MoviesControllerTest < ActionDispatch::IntegrationTest
  describe "index" do
    it "returns a JSON array" do
      get movies_url
      assert_response :success
      @response.headers['Content-Type'].must_include 'json'
      
      # Attempt to parse
      data = JSON.parse @response.body
      data.must_be_kind_of Array
    end
    
    it "should return many movie fields" do
      get movies_url
      assert_response :success
      
      data = JSON.parse @response.body
      data.each do |movie|
        movie.must_include "title"
        movie.must_include "release_date"
      end
    end
    
    it "returns all movies when no query params are given" do
      get movies_url
      assert_response :success
      
      data = JSON.parse @response.body
      data.length.must_equal Movie.count
      
      expected_names = {}
      Movie.all.each do |movie|
        expected_names[movie["title"]] = false
      end
      
      data.each do |movie|
        expected_names[movie["title"]].must_equal false, "Got back duplicate movie #{movie["title"]}"
        expected_names[movie["title"]] = true
      end
    end
  end
  
  describe "show" do
    it "Returns a JSON object" do
      get movie_url(title: movies(:one).title)
      assert_response :success
      @response.headers['Content-Type'].must_include 'json'
      
      # Attempt to parse
      data = JSON.parse @response.body
      data.must_be_kind_of Hash
    end
    
    it "Returns expected fields" do
      get movie_url(title: movies(:one).title)
      assert_response :success
      
      movie = JSON.parse @response.body
      movie.must_include "title"
      movie.must_include "overview"
      movie.must_include "release_date"
      movie.must_include "inventory"
      movie.must_include "available_inventory"
    end
    
    it "Returns an error when the movie doesn't exist" do
      get movie_url(title: "does_not_exist")
      assert_response :not_found
      
      data = JSON.parse @response.body
      data.must_include "errors"
      data["errors"].must_include "title"
      
    end
  end
  
  
  describe "create" do
    before do
      @valid_movie_params = {
        title: "The Martian Elf",
        overview: "Elf brings holiday cheer",
        release_date: "2018-12-25",
        inventory: 4,
        image_url: "http://3.bp.blogspot.com/-Apn2Uh-QAxY/UOwHL_ZCwBI/AAAAAAAACcQ/w7D2IRlCxco/s1600/Nicolas%20Cage%20Lord%20of%20the%20rings%20funny%20images%20rip%20off%20nicolas%20cage%20meme%20elf%20high%20elf%20dark%20elf%20%25285%2529.jpg",
        external_id: 8
      }
      
      @invalid_movie_params ={
        # title is missing
        overview: "Elf brings holiday cheer to the people stranded on Mars",
        release_date: "2018-12-25",
        inventory: 2,
        image_url: "https://mightbegazebos.files.wordpress.com/2016/03/hellboy-2elf.jpg",
        external_id: 17
      }
    end
    
    it "adds a movie to the library, verified by count check" do
      expect {
        post movies_path, params: @valid_movie_params
      }.must_differ "Movie.count", 1
    end
    
    it "newly added movie gives success message and has accurate movie information" do
      post movies_path, params: @valid_movie_params
      body = check_response(expected_type: Hash, expected_status: :ok)
      # check that the body contains the id
      expect(body.keys).must_equal ["id", "title", "overview", "release_date", "inventory", "created_at", "updated_at", "image_url", "external_id"]
      
      new_movie = Movie.find_by(id: body["id"])
      expect(new_movie.title).must_equal @valid_movie_params[:title]
      expect(new_movie.overview).must_equal @valid_movie_params[:overview]
      expect(new_movie.release_date).must_equal Date.parse(@valid_movie_params[:release_date])
      expect(new_movie.inventory).must_equal @valid_movie_params[:inventory]
    end
    
    it "does not affect movie count if the movie is invalid" do
      expect {
        post movies_path, params: @invalid_movie_params
      }.wont_differ "Movie.count"
    end
    
    
    it "responds with an error if the movie is not valid" do
      post movies_path, params: @invalid_movie_params
      body = check_response(expected_type: Hash, expected_status: :not_acceptable)
      expect(body.keys).must_include 'errors'
      expect(body['errors'].keys).must_include "title"
    end
  end
  
end
