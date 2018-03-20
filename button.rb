class Button
  
  attr_accessor :x, :y, :text, :width, :height
  
  def initialize(x, y, z, img_n, img_s)
    @x = x
    @y = y
    @z = z
    @img_n = Image.new(img_n)
    @img_s = Image.new(img_s)
    @font = Font.new($game, Gosu.default_font_name, 25)
    @text = ""
    
    if @img_n.width != @img_s.width or @img_s.height != @img_n.height
      raise "Error : The two image haven't the same size"
    end
    
    @width = @img_n.width
    @height = @img_n.height
    
    @pressed = 0
  end
  
  def hover?
    if $game.mouse_x >= @x and $game.mouse_x <= @x + @width then
      if $game.mouse_y >= @y and $game.mouse_y < @y + @height then
        return true
      end
    end
    return false
  end
  
  def clicked?
    
    if hover? and button_down?(MS_LEFT) and @pressed == 0 then
      @pressed = 1
    end
    
    if !button_down?(MS_LEFT) and @pressed == 1 then
      @pressed = 0
      return true
    end
    
    return false
  end
  
  def draw
    if hover?
      @img_s.draw(@x, @y, @z)
    else
      @img_n.draw(@x, @y, @z)
    end
    
    if @text != "" then
      $font.draw(@text,
                 @x + 10,
                 @y + (@height - $font.height * 0.35) / 2,
                 @z,
                 0.35,
                 0.35,
                 Color::YELLOW)
    end
  end
  
end