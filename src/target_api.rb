require 'httparty'

class Target
	include HTTParty
	base_uri 'https://api.target.com/v2'

	@api_key = 'J5PsS2XGuqCnkdQq0Let6RSfvU7oyPwF'
	@auth = {:key => @api_key}

	def self.opts(query)
		{
				:headers => {'Accept' => 'application/json'},
				:query => @auth.merge(query)
		}
	end

	def self.product_search(searchTerm, q = {})
		q[:searchTerm] = searchTerm
		results = self.get('/products/search', opts(q))
		# returns an array of possible DPCI ids
		results['CatalogEntryView'].map {|e| e['DPCI']}
	end

	def self.product(id, q = {'idType' => 'DPCI'})
		Product.new(self.get("/products/#{id}", opts(q)))
	end

end

class Product
	def initialize(data)
		@data = data['CatalogEntryView'][0]
	end

	def title
		@data['title']
	end

	def price
		@data['Offers'][0]['OfferPrice'][0]['formattedPriceValue']
	end

	def image_url
		@data['Images'][0]['PrimaryImage'][0]['image']
	end

	def render
		require 'erubis'
		view = Erubis::Eruby.new(File.read(File.expand_path 'views/product.erb'))
		view.result(:item => self)
	end
end
