class View

  def initialize(game, controller)
    @game = game
    @controller = controller
  end

  def draw
  	draw_xy
  end

  def draw_xy
    Window.draw_font(0,0,Input.mouse_pos_x.to_s+" "+Input.mouse_pos_y.to_s,Font16)
  end

end