require_relative './lib/tracks_controller'
require_relative '../models/kitten'

class KittensController < TracksController

  protect_from_forgery

  def index
    @kittens = Kitten.all

    render :index
  end

  def new
    render :new
  end

  def create
    @kitten = Kitten.new(
      name: params['kitten']['name'],
      color: params['kitten']['color'],
      breed: params['kitten']['breed'],
    )

    @kitten.save
    redirect_to "/kittens/#{@kitten.id}"
  end

  def show
    @kitten = Kitten.find(params['kitten_id'])

    render :show
  end

  def destroy
    @kitten = Kitten.find(params['kitten_id'])
    @kitten.destroy

    redirect_to '/'
  end
end
