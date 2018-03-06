MenuStar = Struct.new(:x, :y, :angle, :angle_dir, :scale, :type)
MenuShip = Struct.new(:x, :y, :z, :direction, :scale, :speed, :color)

class MenuState
  
  def initialize
    StarAnimation.initialize(800)
    
    @moon_img = Image.new("res/moon.png", :retro => true)
    @earth_img = Image.new("res/planets/planet18.png", :retro => true)
    @star_img = Image.new("res/star.png", :retro => true)
    @little_star_img = Image.new("res/little_star.png")
    @ship_red_img = Image.new("res/menu_ship_red.png")
    @ship_blue_img = Image.new("res/menu_ship_blue.png")
    
    @moon_angle = 0.0
    @earth_angle = 0.0
    
    @clicked = false
    
    @menu_stars = []
      
    @menu_ships = []
      
    @buttons = [
      Button.new(0, 0, 500, "res/button_n.png", "res/button_s.png"),
      Button.new(0, 0, 500, "res/button_n.png", "res/button_s.png")
    ]
    
    @buttons[0].x = ($game.width - @buttons[0].width) / 2
    @buttons[1].x = ($game.width - @buttons[1].width) / 2 
    
    @buttons[0].y = 250
    @buttons[1].y = 350
    
    @buttons[0].text = "Start"
    @buttons[1].text = "Exit"
    
    x = -100
    y = -100
    
    600.times do
      x += rand(10..80)
      if x > $game.width + 100 then
        x = -100
        y += rand(20..100)
      end
      @menu_stars << MenuStar.new(x, y + -50 + rand(100), rand(360.0), rand(2), rand(1..10.0) / 10.0, rand(2))
    end
    
    10.times do
      if rand(2) == 0 then # right
        scale = rand(1..10) / 10.0
        @menu_ships << MenuShip.new($game.width + rand(500..1000), rand($game.height), scale * 150, 0, scale, scale * 5, rand(2))
      else # Left
        scale = rand(1..10) / 10.0
        @menu_ships << MenuShip.new(-rand(500..1000), rand($game.height), scale * 150, 1, scale, scale * 5, rand(2))
      end
    end
    
    @started = false
  end
  
  def update
    
    if Fader::faded_in? and !@started then
      Fader::fade_out(4)
      @started = true
    elsif Fader::faded_in? and @started then
      Fader::fade_out(10)
    end
    
    $menus_channel = $menus_sample.play(1, 1, true) if  $menus_channel == nil or !$menus_channel.playing?
    
    @moon_angle += 0.01
    @earth_angle += 0.05
    
    if @buttons[0].clicked? then
      Fader::fade_in(10)
      @clicked = true
    elsif @buttons[1].clicked? then
      $game.close()
      exit(0)
    end
    
    if Fader::faded_in? and @clicked then
      $game.state = :country
    end
    
    @menu_ships.each do |ship|
      if ship.direction == 0 then
        ship.x += ship.speed
        
        if ship.x > $game.width + 100 then
          ship.x = -rand(500..1000)
          ship.y = rand($game.height)
        end
      else
        ship.x -= ship.speed
        
        if ship.x + @ship_red_img.width * ship.scale < -100 then
          ship.x = $game.width + rand(500..1000)
          ship.y = rand($game.height)
        end
      
      end
    end
  end
  
  def draw
    # Background
    @menu_stars.each do |star|
      if star.type == 0 then
        @star_img.draw_rot(star.x + ($game.mouse_x - $game.width) * (star.scale * 0.1),
                           star.y + ($game.mouse_y - $game.height) * (star.scale * 0.1),
                           0, star.angle, 0.5, 0.5, star.scale, star.scale)
      else
        @little_star_img.draw_rot(star.x + ($game.mouse_x - $game.width) * (star.scale * 0.1),
                                  star.y + ($game.mouse_y - $game.height) * (star.scale * 0.1),
                                  -50, star.angle, 0.5, 0.5, star.scale, star.scale)
      end
      
      if star.angle_dir == 0
        star.angle += 0.1
      else
        star.angle -= 0.1
      end
        
    end
    
    @menu_ships.each do |ship|
      if ship.direction == 0 then
        if ship.color == 0 then
          @ship_red_img.draw(ship.x + ($game.mouse_x - $game.width) * (ship.scale * 0.1),
                             ship.y + ($game.mouse_y - $game.height) * (ship.scale * 0.1),
                             ship.z, ship.scale, ship.scale)
        else
          @ship_blue_img.draw(ship.x + ($game.mouse_x - $game.width) * (ship.scale * 0.1),
                              ship.y + ($game.mouse_y - $game.height) * (ship.scale * 0.1),
                              ship.z, ship.scale, ship.scale)
        end
      else
        if ship.color == 0 then
          @ship_red_img.draw(ship.x + ($game.mouse_x - $game.width) * (ship.scale * 0.1),
                             ship.y + ($game.mouse_y - $game.height) * (ship.scale * 0.1),
                             ship.z, -ship.scale, ship.scale)
        else
          @ship_blue_img.draw(ship.x + ($game.mouse_x - $game.width) * (ship.scale * 0.1),
                              ship.y + ($game.mouse_y - $game.height) * (ship.scale * 0.1),
                              ship.z, -ship.scale, ship.scale)
        end
      end
    end
    
    @moon_img.draw_rot(150 + ($game.mouse_x - $game.width) * (2.5 * 0.1),
                       750 + ($game.mouse_y - $game.height) * (2.5 * 0.1),
                       500, @moon_angle, 0.5, 0.5, 4.0, 4.0)
    @earth_img.draw_rot(850 + ($game.mouse_x - $game.width) * (0.4 * 0.1),
                        150 + ($game.mouse_y - $game.height) * (0.4 * 0.1),
                        100, @earth_angle, 0.5, 0.5, 0.5,  0.5)
                        
    # Text                  
    $font.draw("Space Race",
               ($game.width - $font.text_width("Space Race")) / 2,
               15, 500, 1.0, 1.0, Color::RED)
               
    @buttons.each do |button|
      button.draw()
    end
  end
  
  def reset
    # @song.stop()
    $score = 0
    $distance = 0
    @clicked = false
  end
  
end