class Order
  attr_reader :orders

  def initialize(crops)
  	@crops = crops
  	@orders = datalist.shuffle
  end

  def satisfy?(pos)
  	order = @orders[pos]
  	return false if order[:max] == order[:count]
  	return @crops.find{|c|order[:crop] == c[:name] && c[:amount] >= order[:amount]}
  end

  def fill_order(pos)
  	p "fill_order"
    order = @orders[pos]
    order_crop = @crops.find{|c|order[:crop] == c[:name]}
    order_crop[:amount] -= order[:amount]
    order[:count] += 1
    order[:count_all] += 1    
  end  

  def datalist
  	list = [
  	  {crop: "ジャガイモ", amount: 4, count: 0, max: 3, count_all: 0, waiting: 1, rep: 1},
  	  {crop: "キャベツ", amount: 2, count: 0, max: 1, count_all: 0, waiting: 1, rep: 1},
  	  {crop: "トマト", amount: 2, count: 0, max: 5, count_all: 0, waiting: 1, rep: 1}
  	]
  end

end