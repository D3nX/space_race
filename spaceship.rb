class SpaceShip

  attr_reader :x, :y, :width, :height, :speed, :bullets
  attr_reader :booster_speed, :booster_enabled
  attr_reader :specs

  attr_accessor :is_invicible, :life

  def initialize
    @country = nil

    @orb_alpha = 0
    
    @samples = {shot: Sample.new("res/shot.wav"),
                explosion: Sample.new("res/explosion.wav"),
                collide: Sample.new("res/collide.wav"),
                booster: Sample.new("res/booster_sound.wav")}
                
    @channel = nil

    @x = 0
    @y = 0

    @width = 0
    @height = 0

    @speed = 0.4

    @hspeed = 0.0
    @vspeed = 0.0

    @scale = 0.3

    @color = Color::WHITE

    @last_hdir = nil
    @last_vdir = nil

    @rect_center = Rectangle.new(0, 0, 0, 0)
    @rect_right = Rectangle.new(0, 0, 0, 0)
    @rect_left = Rectangle.new(0, 0, 0, 0)

    @bullets = []

    22.times do
      @bullets << Bullet.new()
    end

    @last_bullet = nil
    
    @bonus_text = BonusText.new()

    @spaceship_name = ""

    # Life stuffs

    @life = 5
    @start_time = 0
    @invicible_time = 0
    @touched = false

    # Boosters stuffs

    @booster_enabled = false

    @booster_start_time = 0.0

    @booster_time = 0.0

    @booster_speed = 0.0

    # For death lightning
    @lightning_count = 0

  end

  def update(boosters, monsters, asteroids)

    # Booster timing stuff
    if !@booster_enabled then
      @booster_start_time = Game.as_seconds()
    else
      # puts "time : #{@booster_time}"
      @booster_time = Game.as_seconds() - @booster_start_time

      if @booster_speed < @booster_speed_to_reach and @booster_time <= 8.0 then
        @booster_speed += 0.1
      else
        if @booster_speed > 0 then
          @booster_speed -= 0.2
        end

        @booster_speed = 0.0 if @booster_speed < 0
      end

      if @booster_time >= 10.0 then
        @booster_start_time = @booster_time
        @booster_time = 0

        @booster_enabled = false

        @booster_start_time = 0.0

        @booster_time = 0.0

        @booster_speed = 0.0

        @booster_speed_to_reach = 0.0

        @is_invicible = false
      end
    end

    # For right and left movement
    if button_down?(KB_RIGHT) then
      if @x + @width * @scale < $game.settings.default_width
        if @last_hdir == :left then
          @hspeed = 1.5
        end
        @hspeed += @speed / 2.0 if @hspeed < 5.0
        @x += @hspeed
        @last_hdir = :right
      else
        @x = $game.settings.default_width - @width * @scale
      end
    elsif button_down?(KB_LEFT) then
      if @x > 0 then
        if @last_hdir == :right then
          @hspeed = 1.5
        end
        @hspeed += @speed / 2.0 if @hspeed < 5.0
        @x -= @hspeed
        @last_hdir = :left
      else
        @x = 0
      end
    else
      @hspeed -= 0.2

      if @hspeed <= 0.0
        @hspeed = 0.0
        @last_hdir = nil
      end

      if @last_hdir == :right then
        if @x + @width * @scale < $game.settings.default_width
          @x += @hspeed
        else
          @hspeed = 0
          @x = $game.settings.default_width - @width * @scale
        end
      elsif @last_hdir == :left then
        if @x > 0
          @x -= @hspeed
        else
          @hspeed = 0
          @x = 0
        end
      end
    end

    # For up and down deplacement
    if button_down?(KB_UP) then
      if @y > 0
        if @last_vdir == :down then
          @vspeed = 1.5
        end
        @vspeed += @speed / 2.0 if @vspeed < 5.0
        @y -= @vspeed
        @last_vdir = :up
      else
        @y = 0
      end
    elsif button_down?(KB_DOWN) then
      if @y + @height * @scale < $game.settings.default_height
        if @last_vdir == :up then
          @vspeed = 0.5
        end
        @vspeed += @speed / 2.0 if @vspeed < 5.0
        @y += @vspeed
        @last_vdir = :down
      else
        @y = $game.settings.default_height - @height * @scale
      end
    else
      @vspeed -= 0.2

      if @vspeed <= 0.0
        @vspeed = 0.0
        @last_vdir = nil
      end

      if @last_vdir == :up then
        if @y > 0 then
          @y -= @vspeed
        else
          @vspeed = 0
          @y = 0
        end
      elsif @last_vdir == :down then
        if @y + @height * @scale < $game.settings.default_height
          @y += @vspeed
        else
          @vspeed = 0
          @y = $game.settings.default_height - @height * @scale
        end
      end
    end

    # Synchronize bullet position
    @bullets.each do |bullet|
      if !bullet.active then
        bullet.x = @x + @width * @scale / 2 - 1
        bullet.y = @y
      end
    end

    # Shoot if needed
    if button_down?(KB_SPACE) then
      if @last_bullet == nil or @last_bullet.start_y - @last_bullet.y >= 100 or !@last_bullet.active then
        @bullets.each do |bullet|
          if !bullet.active then
            bullet.active = true
            bullet.x = (@x + @width * @scale / 2 - 1) - bullet.width / 2
            bullet.y = @y
            @last_bullet = bullet
            @samples[:shot].play(0.2 * ($game.settings.sfx_volume / 100.0))
            break
          end
        end
      end
    end

    # Synchronizing rectangle position
    synchronize_rectangles()
    
    # Check collision between player and boosters
    boosters.each do |booster|
      if booster.collides?(@rect_left) or
         booster.collides?(@rect_right) or
         booster.collides?(@rect_center) then

         booster.reset()

         if !@booster_enabled then
           
          @samples[:booster].play(($game.settings.sfx_volume / 100.0))
             
          if booster.is_a? Boosters::NormalBooster then
            Animation::launch(:normal_booster)

            @booster_time = 0.0
            @booster_speed_to_reach = 3.5
            @booster_enabled = true

          end

          if booster.is_a? Boosters::SuperBooster then
            Animation::launch(:super_booster)

            @booster_time = 0.0
            @booster_speed_to_reach = 4.5
            @booster_enabled = true

          end

          if booster.is_a? Boosters::HyperBooster then
            Animation::launch(:hyper_booster)

            @booster_time = 0.0
            @booster_speed_to_reach = 6.0
            @booster_enabled = true

            @touched = false
            @invincible_time = 0
            @start_time = 0
            @is_invicible = true
            @color = Color::WHITE

          end
        end

      end
    end

    # Check collision between bullet and monster, spaceship and monster
    monsters.each do |monster|

      next if monster == nil

      @bullets.each do |bullet|
        # Bullet
        next if !bullet.active or bullet.y + 10 < 0

        if monster.collides?(bullet) then
          monster.punch!(bullet.damage)
          bullet.active = false

          if monster.dead? then
            @bonus_text.make(monster.x, monster.y, 50)
            $game.score += 50
            @channel.stop if @channel != nil
            @channel = @samples[:explosion].play(($game.settings.sfx_volume / 100.0))
            next
          end
        end
      end

      next if @is_invicible

      # Spaceship
      if (monster.collides?(@rect_left) or
         monster.collides?(@rect_right) or
         monster.collides?(@rect_center)) then
         @samples[:collide].play(($game.settings.sfx_volume / 100.0))
         @life -= 1 if @life > 0
         @touched = true
         @start_time =  Game.as_seconds()
         @invicible_time = @start_time
         @is_invicible = true
         $game.shake
      end
    end
    
    # Asteroid stuff
    asteroids.each do |asteroid|
      
      asteroid.update(@x, @booster_speed + @speed)
      
      @bullets.each do |bullet|
        # Bullet
        next if !bullet.active or bullet.y + 10 < 0

        if asteroid.collides?(bullet.rectangle) then
          asteroid.punch!(1)
          bullet.active = false

          if asteroid.dead? then
            @bonus_text.make(asteroid.x, asteroid.y, 20)
            $game.score += 20
            @samples[:explosion].play(($game.settings.sfx_volume / 100.0))
            next
          end
        end
      end
      
      next if @is_invicible == true
      
      if (asteroid.collides?(@rect_left) or
          asteroid.collides?(@rect_right) or
          asteroid.collides?(@rect_center)) then
        @samples[:collide].play(($game.settings.sfx_volume / 100.0))
        @life -= 1 if @life > 0
        @touched = true
        @start_time =  Game.as_seconds()
        @invicible_time = @start_time
        @is_invicible = true
        $game.shake
      end
    end
    
    # Life stuff
    if @touched and @invicible_time - @start_time < 6 then
      # @lightning_count += 1
      if (@invicible_time - @start_time).to_i % 2 == 1 then
        @color = Color.new(128, 255, 255, 255)
      else
        @color = Color.new(200, 255, 255, 255)
      end
      @invicible_time = Game.as_seconds()
    elsif @invicible_time - @start_time >= 6 and @touched then
      @lightning_count = 0
      @touched = false
      @invincible_time = 0
      @start_time = 0
      @is_invicible = false
      @color = Color::WHITE
    end

  end

  def draw
    
    # if @country == :ussr then
    #   @soviet_spaceship.draw(@x, @y, 500, @scale, @scale, @color)
    # elsif @country == :usa then
    #   @usa_spaceship.draw(@x, @y, 500, @scale, @scale, @color)
    # end

    image = SpriteManager.get_image(@spaceship_name)
    
    image.draw(@x, @y, 500, @scale, @scale, @color)

    if @is_invicible and !@touched then
      if @orb_alpha < 255 and @booster_time <= 8.0 then
        @orb_alpha += 3
      else
        @orb_alpha -= 4
      end
      image.draw(@x - (image.width * (@scale + 0.02) - image.width * @scale)/2,
                 @y - (image.height * (@scale + 0.02) - image.height * @scale)/2,
                 500,
                 @scale + 0.02,
                 @scale + 0.02,
                 Color.new(@orb_alpha, 255, 255, 0))
    end

    @bullets.each do |bullet|
      bullet.draw()
    end
    
    @bonus_text.draw()
    
    return
    @rect_center.draw()
    @rect_right.draw()
    @rect_left.draw()
  end

  def set(country, spaceship_name, specs)
    @country = country
    @spaceship_name = spaceship_name
    @vspeed = 0.0
    @hspeed = 0.0
    @booster_enabled = false
    @booster_start_time = 0.0
    @booster_time = 0.0
    @booster_speed = 0.0

    @orb_alpha = 0
    
    @is_invincible = false
    @invicible_time = 0.0
    @start_time = 0.0
    
    @bonus_text.reset

    # Set the specifications
    @specs = specs

    @speed = (specs[:"speed"] / 10.0) * 2
    @life = specs[:"life"]

    @bullets.each do |b|
      b.damage = specs[:"weapon damage"] / 5.0
    end

    @width = SpriteManager.get_image(@spaceship_name).width
    @height = SpriteManager.get_image(@spaceship_name).height

    @x = ($game.settings.default_width - @width * @scale) / 2
    @y = $game.settings.default_height - @height * @scale - 55

    # Set the rectangles
    @rect_center.width = @width * @scale / 3
    @rect_center.height = @height * @scale - 30

    @rect_right.width = @width * @scale / 3
    @rect_right.height = @height * @scale / 2

    @rect_left.width = @width * @scale / 3
    @rect_left.height = @height * @scale / 2

    # Set the country bullet color
    if @country == :ussr then
      @bullets.each do |bullet|
        bullet.make_red()
        bullet.x = @x + @width * @scale / 2 - 1
        bullet.y = @y
        bullet.active = false
      end
    else
      @bullets.each do |bullet|
        bullet.make_blue()
        bullet.x = @x + @width * @scale / 2 - 1
        bullet.y = @y
        bullet.active = false
      end
    end

    synchronize_rectangles()
  end

  private

  def synchronize_rectangles()
    @rect_center.x = @x + (@width * @scale - @rect_center.width) / 2
    @rect_center.y = @y

    @rect_right.x = @x + @width * @scale - @rect_right.width
    @rect_right.y = @y + @height * @scale - @rect_right.height

    @rect_left.x = @x
    @rect_left.y = @y + @height * @scale - @rect_left.height
  end

end
