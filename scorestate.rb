class ScoreState

    def initialize
        @buttons = []

        button = Button.new(0, 0, 500, "res/button_n.png", "res/button_s.png")

        1.times { @buttons << button }

        @buttons[0].text = "Go back"
        @buttons[0].x = 5
        @buttons[0].y = $game.settings.default_height - @buttons[0].height - 5

        @next_state = nil

        load_score()

        # p @scores
    end

    def update
        if @buttons[0].clicked?
            @next_state = :menu
        end

        if Fader::faded_out? and @next_state != nil
            Fader::fade_in(10)
        elsif Fader::faded_in? and @next_state != nil
            $game.state = @next_state
        end
    end

    def draw
        # Star Animation
        StarAnimation.draw

        # Draw buttons
        @buttons.each { |b| b.draw }

        # Draw title
        $font.draw("Scores",
                   ($game.settings.default_width - $font.text_width("Scores")) / 2,
                   15, 500, 1.0, 1.0, Color::YELLOW)

        # Draw panel score
        Gosu.draw_rect(($game.settings.default_width - 900) / 2 - 3,
                       117,
                       906,
                       $game.settings.default_height / 1.5 + 6,
                       Color::YELLOW,
                       500)

        Gosu.draw_rect(($game.settings.default_width - 900) / 2,
                       120,
                       900,
                       $game.settings.default_height / 1.5,
                       Color.new(255, 51, 51, 51),
                       500)

        Gosu.draw_rect(($game.settings.default_width - 900) / 2 - 3,
                       175,
                       906,
                       3,
                       Color::YELLOW,
                       500)

        Gosu.draw_rect(($game.settings.default_width - 900) / 2 + 900 / 2 - 3,
                       120,
                       3,
                       $game.settings.default_height / 1.5,
                       Color::YELLOW,
                       500)

        # Draw score text
        y = 180
        i = 0
        @scores.each do |k, v|
            $font.draw(k.split("_")[0],
                       ($game.settings.default_width - 900) / 2 + 15,
                       y,
                       500,
                       0.4,
                       0.4,
                       Color::YELLOW)

            $font.draw(v,
                       ($game.settings.default_width - 900) / 2 + 900/2 + 15,
                       y,
                       500,
                       0.4,
                       0.4,
                       Color::YELLOW)

            y += $font.height * 0.4 + 10

            i += 1

            break if i == 10
        end

        $font.draw("Date :",
                   ($game.settings.default_width / 2 - 900 / 2)+(900/2 - $font.text_width("Date :", 0.4))/2,
                   130,
                   500,
                   0.4,
                   0.4,
                   Color::YELLOW)

        $font.draw("Score :",
                   ($game.settings.default_width / 2)+(900/2 - $font.text_width("Score :", 0.4))/2,
                   130,
                   500,
                   0.4,
                   0.4,
                   Color::YELLOW)


        i += 1
    end

    def reset
        @next_state = nil

        load_score()
    end

    def set_volume; end

    private

    def load_score
        @scores = {}

        File.open("data/scores.txt", "r") do |f|
            i = 0
            f.each_line do |line|
                @scores[line.split(":")[0]+"_#{i}"] = line.split(":")[1].gsub("\n", "")
                i += 1
            end
        end

        @scores = @scores.to_a.reverse.to_h
    end

end