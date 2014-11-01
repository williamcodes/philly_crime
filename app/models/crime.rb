require "net/http"
require "uri"

class Crime < ActiveRecord::Base
	@base_uri = 'https://torid-torch-5520.firebaseio.com/'
	@philly_uri = URI.parse("http://gis.phila.gov/ArcGIS/rest/services/PhilaGov/Police_Incidents_Last30/MapServer/0/query?text=&geometry=&geometryType=esriGeometryPoint&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&objectIds=&where=sector+NOT+LIKE+%27%25%5B%5E0-9%5D%25%27&time=&returnCountOnly=false&returnIdsOnly=false&returnGeometry=true&maxAllowableOffset=&outSR=&outFields=*&f=pjson")

	def self.update
		get_from_philly
		send_to_firebase
	end

	def self.get_from_philly
		response = Net::HTTP.get_response(@philly_uri)
		crimes = JSON.parse(response.body)['features']
		crimes.each do |crime|
			find_or_create_by parse(crime)
		end
	end

	def self.send_to_firebase
		clear_firebase
		build_firebase
	end

	def self.parse(params)
		return {
			text_general_code: params['attributes']['TEXT_GENERAL_CODE'],
			x: params['attributes']['POINT_X'],
			y: params['attributes']['POINT_Y']
		}
	end

	def self.clear_firebase
		Firebase::Client.new(@base_uri).delete('crimes')
	end

	def self.build_firebase
		Firebase::Client.new(@base_uri).set('crimes', all.map{|crime| crime.to_fire})
	end

	def to_fire
		{lat: self.x, lon: self.y, title: self.text_general_code}
	end
end
