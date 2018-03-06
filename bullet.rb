class Bullet
  
  SPEED = 10
  
  attr_reader :x, :y, :active, :rectangle
  attr_accessor :dy, :start_y, :damage
  
  def initialize
    @x = 0
    @y = 0
    
    @color = Color::WHITE
    
    @start_y = 0
    
    @active = false
        
    @dy = 0
    
    @damage = 4
    
    @rectangle = Rectangle.new(0, 0, 5, 10)
  end
  
  def draw
    
    if @dy <= @y and @active then
      
      @y -= SPEED

      if @y + 10 > 0 and @active then
        Gosu.draw_line(
          @x, @y, @color,
          @x, @y + 10, @color,
          500
        )
      end
    else
      @active = false
    end
    
    @rectangle.x = @x
    @rectangle.y = @y
  end
  
  def active=(v)
    @active = v
    @dy = -$game.height
  end
  
  def x=(dx)
    @x = dx
  end
  
  def y=(dy)
    @y = dy
    @start_y = dy
  end
  
  def make_blue()
    @color = Gosu::Color.new(255, 32, 32, 255)
  end

  def make_red()
    @color = Gosu::Color.new(255, 255, 32, 32)
  end
  
  def make_yellow()
    @color = Gosu::Color::YELLOW
  end
  
  def collides?(rect)
    return rect.collides?(@rectangle)
  end
  
end