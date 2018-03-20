class Asteroid
  
  attr_reader :x, :y
  
  def initialize
    if !defined? @@imgs then
      @@imgs = [Image.new("res/asteroids/asteroid_0.png")]
      @@lose_animation = Image.load_tiles("res/explosion.png", 64, 64, :retro => true).reverse
      @@smokes_img = [
        Image.new("res/smoke_0.png"),
        Image.new("res/smoke_1.png"),
        Image.new("res/smoke_2.png")
      ]
    end
    
    @current_image = rand(@@imgs.size)
    @currents_smoke = rand(@@smokes_img.size)
    
    @lose_time = 0
    @lose_limit = @@lose_animation.size * 10
    @lose_alpha = 0
    
    @x = rand(0..$game.width)
    @y = -@@imgs[@current_image].height - rand(1000..10000)
    
    @angle = rand(360)
    
    @angle_speed = rand(15.0..30.0) / 10.0
    
    @speed = rand(200.0..350.0) / 100.0
    
    @rectangle = Rectangle.new(0, 0, @@imgs[@current_image].width - 60, @@imgs[@current_image].height - 60)
      
    @last_life = 6
    @life = @last_life
    
    @y = -@@imgs[@current_image].height - rand(1000..25000)
  end
  
  def update(player_x, booster_speed)
    @x -= (player_x - $game.width / 2) * 0.2
    
    if @lose_time != -1 and !dead? then
      @y += @speed + booster_speed
    elsif @lose_time == -1
      @y += @speed * 0.5 + booster_speed
    end
    
    @angle += @angle_speed
    
    if dead? then
      if @lose_time == -1 then
        @y += 6 + booster_speed
      else
        @y += @speed + booster_speed
      end
    end
    
    if @lose_time != -1 and
      @life <= 0 and
      @lose_time < @lose_limit then
      
      @lose_time += 6
    elsif dead? then
      @current_smoke = rand(@@smokes_img.size) if @lose_time != -1
      @lose_time = -1
      @lose_alpha += 5 if @lose_alpha < 200
    end
    
    if @y - @@imgs[@current_image].height > $game.height then
      reset()
    end
    
    @rectangle.x = @x + -@@imgs[@current_image].width / 2 + 30
    @rectangle.y = @y + -@@imgs[@current_image].height / 2 + 30
  end
  
  def draw(player_x = nil)
    if @life != @last_life and !dead? then
      @@imgs[@current_image].draw_rot(@x, @y, 500, @angle, 0.5, 0.5, 1.0, 1.0, Color::RED)
      @last_life = @life
    elsif !dead?
      @@imgs[@current_image].draw_rot(@x, @y, 500, @angle)
    else
      if @lose_time != -1 then
        @@lose_animation[(@lose_time / 10 % @@lose_animation.size).to_i].draw(@x, @y, 400, 2.0, 2.0)
      else
        @@smokes_img[@current_smoke].draw(@x, @y, 400, 0.5, 0.5, Color.new(@lose_alpha, 255, 255, 255))
      end
    end
    # @rectangle.draw()
      
    @x += (player_x - $game.width / 2) * 0.2 if player_x != nil
  end
  
  def reset
    @y = -@@imgs[@current_image].height - rand(1000..10000)
            
    n_p = rand(2) == 1 ? 1 : -1 # negative of positive
    @angle_speed = (n_p * rand(15.0..30.0)) / 10.0
    @lose_time = 0
    @speed = rand(30.0..45.0) / 10.0
    @lose_alpha = 0
    @last_life = 6
    @life = @last_life
  end
  
  def collides?(rect)
    return false if dead?
    return @rectangle.collides?(rect)
  end
  
  def punch!(damage)
    @life -= damage if @life > 0
  end
  
  def dead?
    return @life <= 0
  end
  
end