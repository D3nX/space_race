class Button
  
  attr_accessor :x, :y, :width, :height
  attr_reader :text

  PathPair = Struct.new(:path_n, :path_s)
  
  def initialize(x, y, z, img_n, img_s)

    @x = x
    @y = y
    @z = z
    @text_x = 0
    @img_n = Image.new(img_n)
    @img_s = Image.new(img_s)
    @font = Font.new($game, Gosu.default_font_name, 25)
    @text = ""
    
    if @img_n.width != @img_s.width or @img_s.height != @img_n.height
      raise "Error : The two image haven't the same size!"
    end
    
    @width = @img_n.width
    @height = @img_n.height
    
    @pressed = 0
  end
  
  def hover?
    if $game.settings.mouse_x >= @x and $game.settings.mouse_x <= @x + @width
      if $game.settings.mouse_y >= @y and $game.settings.mouse_y < @y + @height
        return true
      end
    end
    return false
  end
  
  def clicked?
    
    if hover? and button_down?(MS_LEFT) and @pressed == 0
      @pressed = 1
    end
    
    if !button_down?(MS_LEFT) and @pressed == 1
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
    
    if @text != ""
      $font.draw(@text,
                 @x + @text_x,
                 @y + (@height - $font.height * 0.35) / 2,
                 @z,
                 0.35,
                 0.35,
                 Color::YELLOW)
    end
  end
  
  def text=(txt)
    @text = txt

    @text_x = (@width - $font.text_width(txt, 0.35))/2
  end

end