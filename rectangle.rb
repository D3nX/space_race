class Rectangle
  
  attr_accessor :x, :y, :width, :height
  
  def initialize(x, y, width, height)
    @x = x
    @y = y
    @width = width
    @height = height
  end
   
  def draw
    Gosu.draw_rect(
      @x,
      @y,
      @width,
      @height,
      Color::WHITE,
      500
    )
  end
  
  def collides?(rectangle)
    if !rectangle.is_a? Rectangle then
      raise "Error : This is not a rectangle !"
    end
    
    if rectangle.x + rectangle.width < @x or
       rectangle.x > @x + @width or
       rectangle.y + rectangle.height < @y or
       rectangle.y > @y + @height then
      return false
    end
    
    return true
  end
  
end