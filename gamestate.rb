class GameState

  def initialize

    @spaceship = SpaceShip.new()
    @song = Song.new("res/game_main.mp3")

    @boosters = [
      Boosters::NormalBooster.new(),
      Boosters::NormalBooster.new(),
      Boosters::SuperBooster.new(),
      Boosters::SuperBooster.new(),
      Boosters::HyperBooster.new(),
      Boosters::HyperBooster.new()
    ]
    
    @asteroids = []
      
    25.times { @asteroids << Asteroid.new() }
      
    @formations = [Formation.new("res/formations/formation_0.f", 500, 1500, Monsters::BouncingShip),
                   Formation.new("res/formations/formation_1.f", 1000, 2000, Monsters::BouncingShip),
                   Formation.new("res/formations/formation_2.f", 700, 1400, Monsters::BlitzShip)]

    @monsters = []

    @formations.each { |f| @monsters += f.monsters }

    @home_button = Button.new(0, 0, 500, "res/home_n.png", "res/home_s.png")
    @home_button.y = $game.settings.default_height - @home_button.height

    @clicked = false

    @gameover = false

    @life_bar = ProgressBar.new(200, 24, 100)
    @life_bar.position.x = $game.settings.default_width - @life_bar.width - 10
    @life_bar.position.y = 5

  end

  def update

    if Fader::faded_in? and !@clicked and !@gameover then
      Fader::fade_out(10)
    elsif Fader::faded_in? and @clicked and !@gameover then
      @spaceship.life = @spaceship.specs[:"life"]
      $game.score = 0.0
      $game.distance = 0.0
      $game.state = :menu
    elsif Fader::faded_in? and @gameover then
      $game.state = :gameover
    end

    @spaceship.update(@boosters, @monsters, @asteroids) if !@gameover
    
    if @spaceship.life <= 0 and !@gameover then
      @tmp_img = Gosu.record($game.settings.default_width, $game.settings.default_height) { draw() }
      @gameover = true
      Fader::fade_in(10)
    end

    if !@gameover then
      @formations.each { |f| f.update(@spaceship.x, @spaceship.booster_speed + @spaceship.speed) }
      @song.play(true) if !@song.playing? and $game.state == :game
      @boosters.each do |booster|
        if @spaceship.booster_enabled then
           if booster.y + booster.img.height > 0 and booster.y < $game.settings.default_height then
             booster.update(@spaceship.x, @spaceship.booster_speed + @spaceship.speed, true)
           else
             booster.update(@spaceship.x, @spaceship.booster_speed + @spaceship.speed, false)
           end
        else
          booster.update(@spaceship.x, @spaceship.booster_speed + @spaceship.speed, true)
        end
      end
      Animation::update()
    end

    if @home_button.clicked? then
      Fader::fade_in(10)
      @clicked = true
    end

    @asteroids.each { |asteroid| asteroid.update(@spaceship.x, 0.0, false) } if @gameover

    # Updating progress bar
    @life_bar.percentage = @spaceship.life * 100 / @spaceship.specs[:"life"]
    @life_bar.text = @spaceship.life.to_s

  end

  def draw

    # Game
    StarAnimation.draw(@spaceship.x, @spaceship.booster_speed + @spaceship.speed)

    @spaceship.draw()

    if !@gameover
      @boosters.each { |booster| booster.draw(@spaceship.x) }
      @asteroids.each { |asteroid| asteroid.draw(@spaceship.x) }
    else
      @boosters.each { |booster| booster.draw() }
      @asteroids.each { |asteroid| asteroid.draw(@spaceship.x) }
    end

    @formations.each { |f| f.draw(@spaceship.x) }

    @home_button.draw()

    # Ui
    # Gosu.draw_rect(0, $game.settings.default_height - 50,
    #                $game.settings.default_width, 50,
    #                Color.new(150, 16, 16, 255), 500)

    $font.draw("Score : #{$game.score.to_i}",
               5,
               3,
               500, 0.3, 0.4,
               Color::WHITE)

    $font.draw("Life :",
               $game.settings.default_width - @life_bar.width - $font.text_width("Life :", 0.3) - 15,
               3,
               500, 0.3, 0.4,
               Color::WHITE)

    $font.draw("Distance : #{$game.distance.to_i} meters",
               ($game.settings.default_width - $font.text_width("Distance : #{$game.distance.to_i} meters", 0.3)) / 2,
               3,
               500, 0.3, 0.4,
               Color::WHITE)

    @life_bar.draw

    Animation::draw()

    $game.distance += 1 + @spaceship.speed + @spaceship.booster_speed
    $game.score += 0.1
  end

  def reset
    @song.stop()
    @clicked = false
    @gameover = false
    Animation::reset()
    
    # Reseting everythings
    @boosters.each { |b| b.reset }
    @monsters.each { |m| m.reset }
    @asteroids.each { |a| a.reset }
  end

  def set_spaceship(country, current_spaceship, spec)
    @spaceship.set(country, current_spaceship, spec)
  end

  def set_volume
    @song.volume = ($game.settings.music_volume / 100.0)
  end

end