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
    self.get('/products/search', opts(q))
  end

end
