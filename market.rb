class Market
attr_reader :prices

  def initialize
  	@prices = []
  	SEEDS.each do |seed|
  	  @prices.push({name: seed[:name], price: rand(60), demand: 0, supply: 0, last_demand: 0, last_supply: 0})
  	end
  end

  def prices_in_season(name_array)
    @prices.find_all{|p|name_array.include?(p[:name])}
  end

end