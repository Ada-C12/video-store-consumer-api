class Customer < ApplicationRecord
  has_many :rentals
  has_many :movies, through: :rentals

  def movies_checked_out_count
    self.rentals.where(returned: false).length
  end

  def movie_names
    movies_list = self.movies
    array = []
    movies_list.each do |movie|
      array << movie.title
    end
    return array.to_sentence
  end
end
