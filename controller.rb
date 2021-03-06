require 'native' 

class Controller
  attr_reader :x,:y,:mx,:my

  def initialize(game)
    @game = game
  end

  def input
    @mx = Input.mouse_x
    @my = Input.mouse_y
    if Input.mouse_push?( M_LBUTTON )
      case @game.status
      when :title
        case pos_title_menu
        when 0 
          @game.start
        when 1 
          @game.stats
        when 2 
          @game.ranking
        end
      when :game
        click_on_game
      when :stats
      when :ranking
      when :end
      end
    end
    if(Input.key_push?(K_SPACE))
      case @game.status
      when :game
      end
    end
  end

  def click_on_game
    if pos_main_menu != -1
      @game.click_menu(pos_main_menu)
    elsif @game.mainview == :farm && pos_farm != -1
      @game.click_farm(pos_farm)
    elsif @game.mainview == :orders && pos_order != -1
      @game.click_order(pos_order)
    elsif @game.mainview == :market && pos_market != -1
      @game.click_market(pos_market)
    elsif @game.mainview == :shop && pos_shop != -1
      @game.click_shop(pos_shop)
    end
  end

  def pos_farm
    4.times do |x|
      3.times do |y|
        return x+y*4 if mcheck(30+(FARM_SIZE+10)*x,30+(FARM_SIZE+10)*y,30+FARM_SIZE+(FARM_SIZE+10)*x,30+FARM_SIZE+(FARM_SIZE+10)*y)
      end
    end
    return -1
  end

  def pos_order
    return pos_main_view_list(@game.orders.size)
  end

  def pos_market
    return pos_main_view_list(@game.market.prices_in_season(@game.crops_of_season).size)
  end

  def pos_shop
    return pos_main_view_list(@game.seeds_of_season.size)
  end

  def pos_main_view_list(size)
    size.times do |i|
      return i if mcheck(MAIN_VIEW_LIST_X, MAIN_VIEW_LIST_Y+24*i, MAIN_VIEW_LIST_X+MAIN_VIEW_LIST_WIDTH, MAIN_VIEW_LIST_Y+20+24*i)
    end
    return -1
  end

  def pos_title_menu
    3.times do |i|
      return i if(mcheck(TITLE_MENU_X, TITLE_MENU_Y[i], TITLE_MENU_X+get_width(TITLE_MENU_TEXT[i]), TITLE_MENU_Y[i]+32))
    end
    return -1
  end

  def pos_main_menu
    20.times do |i|
      return i if(mcheck(640-MAIN_MENU_WIDTH, HEADER_HEIGHT+MENU_EACH_HEIGHT*i, 640, HEADER_HEIGHT+MENU_EACH_HEIGHT*(i+1)))
    end
    return -1
  end

  def get_width(str)
    canvas = Native(`document.getElementById('dxopal-canvas')`)
    width = canvas.getContext('2d').measureText(str).width
    return width
  end

  def mcheck(x1,y1,x2,y2)
    x1 < @mx && x2 > @mx && y1 < @my && y2 > @my    
  end

end