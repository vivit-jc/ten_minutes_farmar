class View

  def initialize(game, controller)
    @game = game
    @controller = controller

    @farmback = Image.new(FARM_SIZE, FARM_SIZE)
    @farmback.box(3, 3, FARM_SIZE-4, FARM_SIZE-4, WHITE)
  end

  def draw
    draw_xy
    draw_debug
    case @game.status
    when :title
      draw_title
    when :game
      draw_game
    when :stats
      draw_stats
    end
  end

  def draw_game
    draw_date
    draw_main_menu
    draw_farm
  end

  def draw_farm
    4.times do |x|
      3.times do |y|
        Window.draw(30+(FARM_SIZE+10)*x,30+(FARM_SIZE+10)*y,@farmback)
        if @game.farm[y][x][:kind] == :wasteland
          Window.draw_font(45+(FARM_SIZE+10)*x, 41+(FARM_SIZE+10)*y, "開墾", Font16)
          Window.draw_font(45+(FARM_SIZE+10)*x, 61+(FARM_SIZE+10)*y, "#{@game.farm[y][x][:prog]}/#{@game.farm[y][x][:max]}", Font16)
        else
          Window.draw_font(52+(FARM_SIZE+10)*x, 50+(FARM_SIZE+10)*y, @game.farm[y][x][:str], Font16)
        end
      end
    end
  end

  def draw_date
    date = @game.date
    Window.draw_font(640 - MAIN_MENU_WIDTH, 8, "#{date[:year]}年目 #{season_j(date[:season])} 第#{date[:week]+1}週", Font24)
  end

  def draw_main_menu
    MAIN_MENU_TEXT.each_with_index do |(k,v),i|
      Window.draw_font(640 - MAIN_MENU_WIDTH + 30, CLOCK_HEIGHT+MENU_EACH_HEIGHT*i+5, v, Font20, mouseover_color(@controller.pos_main_menu == i)) 
    end
  end

  def draw_title
    Window.draw(0,0,Image[:title])
    Window.draw_font(20, 20, "10 MINUTES FARMER", Font50, {color: YELLOW})
    
    TITLE_MENU_TEXT.each_with_index do |menu,i|
      Window.draw_font(TITLE_MENU_X,TITLE_MENU_Y[i],menu,Font32,mouseover_color(@controller.pos_title_menu == i, YELLOW)) 
    end
  end

  def draw_message
    @game.messages.each_with_index do |text, i|
      Window.draw_font(10, 480-MESSAGE_BOX_HEIGHT+i*22, text, Font20) 
    end
  end

  def season_j(num)
    ["春","夏","秋","冬"][num]
  end

  def draw_xy
    Window.draw_font(0,0,Input.mouse_pos_x.to_s+" "+Input.mouse_pos_y.to_s,Font16)
  end

  def draw_debug
    Window.draw_font(0,20,@game.debug_arg.to_s,Font16)
  end

  def mouseover_color(bool, color=WHITE)
    return {color: GREEN} if bool
    return {color: color}
  end

end