class Api::Map::LocationsController < Api::ApplicationController
  before_action :verify_json_request, only: %i[show]

  def show
    render json: location
  end

  private

  def location
    return polygons if location_search.search_with_polygons?

    [marker]
  end

  def location_search
    @location_search ||= Search::LocationBuilder.new(params[:id], params[:radius])
  end

  def polygons
    location_search.polygon_boundaries.map { |boundary| polygon(boundary) }
  end

  def polygon(boundary)
    {
      type: "polygon",
      data: {
        point: Geocoding.new(params[:id]).coordinates,
        meta: {},
        coordinates: coordinates(boundary),
      },
    }
  end

  def marker
    {
      type: "marker",
      data: {
        point: location_search.point_coordinates,
      },
    }
  end

  def coordinates(boundary)
    boundary.each_slice(2).map { |element| { lat: element.first, lng: element.second } }
  end
end
