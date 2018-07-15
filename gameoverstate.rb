class GameOverState

  def initialize
    @buttons = [Button.new(0, 0, 500, "res/button_n.png", "res/button_s.png"),
                Button.new(0, 0, 500, "res/button_n.png", "res/button_s.png")]

    @buttons[0].text = "Go Menu"
    @buttons[0].x = 5
    @buttons[0].y = $game.settings.default_height - @buttons[0].height - 5

    @buttons[1].text = "Exit"
    @buttons[1].x = $game.settings.default_width - @buttons[1].width - 5
    @buttons[1].y = $game.settings.default_height - @buttons[1].height - 5

    @defining_score = false

    @final_score = 0

    @quitting = false

    # Scale stuffs
    @scale = 0.0
    @scale_time = 0.0
  end

  def update

    $menus_channel = $menus_sample.play(($game.settings.music_volume / 100.0), 1, true) if  $menus_channel == nil or !$menus_channel.playing?

    if Fader::faded_in? then
      Fader::fade_out(10)
      $game.stop_shaking!
    end

    if @defining_score
      @final_score += 100 if @final_score < ($game.score + $game.distance).to_i
      @final_score = ($game.score + $game.distance).to_i if @final_score > ($game.score + $game.distance).to_i
      if @final_score == ($game.score + $game.distance).to_i then
        @defining_score = false
      end
    else
      @scale_time += 0.1
      @scale = 0.8 + Math::sin(@scale_time) * 0.1
    end

    if !@defining_score
      passed = false
      if @buttons[0].clicked?
        @quitting = true
        Fader::fade_in(10)
        passed = true
      elsif @buttons[1].clicked?
        $game.close()
        exit(0)
        passed = true
      end

      if passed
        File.open("data/scores.txt", "a") do |f|
          time = Time.new
          date = time.day.to_s + "/" + time.month.to_s + "/" + time.year.to_s
          f.write("#{date}:#{@final_score}\n")
        end
      end
    end

    if Fader::faded_in? and @quitting then
      $game.score = 0
      $game.distance = 0
      $game.state = :menu
    end

  end

  def draw
    StarAnimation.draw()

    @buttons.each do |button|
      button.draw()
    end

    $font.draw("Final score : #{@final_score.to_i} !",
               ($game.settings.default_width - $font.text_width("Final score : #{@final_score.to_i} !", @scale)) / 2,
               50,
               500,
               @scale,
               @scale + 0.1,
               Color::YELLOW)

    $font.draw("Game score : #{$game.score.to_i} points",
               ($game.settings.default_width - $font.text_width("Distance travelled : #{$game.distance.to_i} meters", 0.4)) / 2,
               250,
               500,
               0.4,
               0.5,
               Color::RED)

    $font.draw("Distance travelled : #{$game.distance.to_i} meters",
               ($game.settings.default_width - $font.text_width("Distance travelled : #{$game.distance.to_i} meters", 0.4)) / 2,
               350,
               500,
               0.4,
               0.5,
               Color::RED)
  end

  def reset
    @scale_time = 0.0
    @scale = 0.8
    @defining_score = true
    @final_score = $game.score.to_i
    @quitting = false
  end

  def set_volume; end

end
