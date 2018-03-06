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
    
    @rect = Rectangle.new(0, 0, 350, 64)
    
    @formations = [Formation.new("res/formations/formation_0.f", 500, 1500),
                   Formation.new("res/formations/formation_1.f", 1000, 2000),
                   Formation.new("res/formations/formation_2.f", 700, 1400)]
                  
    @monsters = []
      
    @formations.each { |f| @monsters += f.monsters }
    
    @home_button = Button.new(0, 0, 500, "res/home_n.png", "res/home_s.png")
    
    @clicked = false
    
    @gameover = false
    
  end
  
  def update
    
    if Fader::faded_in? and !@clicked and !@gameover then
      Fader::fade_out(10)
    elsif Fader::faded_in? and @clicked and !@gameover then
      $game.state = :menu
    elsif Fader::faded_in? and @gameover then
      $game.state = :gameover
    end
    
    @spaceship.update(@boosters, @monsters) if !@gameover
    
    if @spaceship.life <= 0 and !@gameover then
      @tmp_img = Gosu.record($game.width, $game.height) { draw() }
      @gameover = true
      Fader::fade_in(10)
    end
    
    if !@gameover then
      @formations.each { |f| f.update(@spaceship.booster_speed) }
      @song.play() if !@song.playing? and $game.state == :game
      @boosters.each { |booster| booster.update(@spaceship.x, @spaceship.booster_speed) }
      Animation::update()
    end
    
    if @home_button.clicked? then
      Fader::fade_in(10)
      @clicked = true
    end
  
  end

  def draw
    
    # Game
    StarAnimation.draw(@spaceship.x, @spaceship.booster_speed)
    
    @spaceship.draw()
    
    if !@gameover
      @boosters.each { |booster| booster.draw(@spaceship.x) }
    else
      @boosters.each { |booster| booster.draw() }
    end
      
    @formations.each { |f| f.draw() }
    
    @home_button.draw()
    
    # Ui
    Gosu.draw_rect(0, $game.height - 50,
                   $game.width, 50,
                   Color.new(200, 128, 128, 128), 500)
    
    $font.draw("Score : #{$score.to_i}",
               5,
               $game.height - $font.height * 0.4 - 10,
               500, 0.3, 0.4,
               Color::RED)
               
    $font.draw("Life : #{@spaceship.life}",
               $game.width - $font.text_width("Life : #{@spaceship.life}", 0.3) - 5,
               $game.height - $font.height * 0.4 - 10,
               500, 0.3, 0.4,
               Color::RED)
               
    $font.draw("Distance : #{$distance.to_i} meters",
               ($game.width - $font.text_width("Distance : #{$distance.to_i} meters", 0.3)) / 2,
               $game.height - $font.height * 0.4 - 10,
               500, 0.3, 0.4,
               Color::RED)
    
    Animation::draw()
               
    $distance += 1 + @spaceship.booster_speed
    $score += 0.1
  end

  def reset
    @song.stop()
    @boosters.each { |b| b.reset }
    @monsters.each { |m| m.reset }
    @clicked = true
    @gameover = false
    Animation::reset()
  end
  
  def set_spaceship_country(country)
    @spaceship.set_country(country)
  end
    
end