class Movie < ApplicationRecord
  has_many :rentals
  has_many :customers, through: :rentals
  
  def available_inventory
    self.inventory - Rental.where(movie: self, returned: false).length
  end
  
  def self.no_available_movie_count(external_id, image_url)
    availableMovie = Movie.find_by(external_id: external_id)
    if availableMovie
      availableMovie.image_url = image_url
      availableMovie.inventory = (availableMovie.inventory || 0) + 1
      availableMovie.save
      return true
    end
    return false
  end
  
  def image_url
    raw_value = read_attribute :image_url
    if !raw_value
      MovieWrapper::DEFAULT_IMG_URL
    elsif /^https?:\/\//.match?(raw_value)
      raw_value
    else
      MovieWrapper.construct_image_url(raw_value)
    end
  end
end
