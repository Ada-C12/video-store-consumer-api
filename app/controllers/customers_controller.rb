class CustomersController < ApplicationController
  SORT_FIELDS = %w(name registered_at postal_code)
  
  before_action :parse_query_args
  
  def index
    if @sort    # if the @sort came thru via API queries
      data = Customer.all.order(@sort)
    else
      data = Customer.all 
    end
    
    # I added the following line to preserve the id order
    data = data.sort_by { |customerObj| customerObj.id }  
    
    # I'm turning off their pre-written pagination, otherwise it will break b/c it doesn't get along with data.sort_by above
    # data = data.paginate(page: params[:p], per_page: params[:n])
    
    
    
    render json: data.as_json(
      only: [:id, :name, :registered_at, :address, :city, :state, :postal_code, :phone, :account_credit],
      methods: [:movies_checked_out_count]
    )
  end
  
  private
  def parse_query_args
    errors = {}
    @sort = params[:sort]
    if @sort and not SORT_FIELDS.include? @sort
      errors[:sort] = ["Invalid sort field '#{@sort}'"]
    end
    
    unless errors.empty?
      render status: :bad_request, json: { errors: errors }
    end
  end
end
