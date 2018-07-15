class SelectorState

    def initialize
        @just_entered = true

        @selector_bars = {
            ussr: SelectorBar.new(256, "Soyouz X9", "Soyouz X10"),
            usa: SelectorBar.new(256, "Nasa Falcon I", "Nasa Falcon II")
        }

        @specs = {
            "Soyouz X9" => {
                "speed": 2,
                "life": 5,
                "weapon damage": 5,
                "_guns": [Vec2.new(124,1), Vec2.new(255, 1)]
            },
            "Soyouz X10" => {
                "speed": 8,
                "life": 6,
                "weapon damage": 3,
                "_guns": [Vec2.new(19, 204), Vec2.new(329, 303)]
            },
            "Nasa Falcon I" => {
                "speed": 4,
                "life": 4,
                "weapon damage": 3,
                "_guns": [Vec2.new(196, 0), Vec2.new(355, 0)]
            },
            "Nasa Falcon II" => {
                "speed": 5,
                "life": 5,
                "weapon damage": 3,
                "_guns": [Vec2.new(132, 3), Vec2.new(256, 3)]
            }
        }

        @next_country = nil

        @next_state = nil

        @buttons = []

        button = Button.new(0, 0, 500, "res/button_n.png", "res/button_s.png")

        1.times { @buttons << button }

        @buttons[0].text = "Go back"
        @buttons[0].x = 5
        @buttons[0].y = $game.settings.default_height - @buttons[0].height - 5
    end

    def update

        @selector_bars[@next_country].update()

        # For quitting state
        if bc = @buttons[0].clicked? or button_down?(Gosu::KbReturn)
            if Fader::faded_out? and @next_state == nil
                # $game.states[:game].set_spaceship_country(@next_country)
                @next_state = (bc) ? :country : :game

                if @next_state == :game
                    $menus_channel.stop if $menus_channel != nil
                    
                    $game.states[:game].set_spaceship(@next_country,
                                                      @selector_bars[@next_country].current_element,
                                                      @specs[@selector_bars[@next_country].current_element])
                end

                Fader::fade_in(10)
            end
        end if !@selector_bars[@next_country].moving

        if @next_state != nil and Fader::faded_in?
            $game.state = @next_state
        end

    end

    def draw
        StarAnimation::draw($game.width/2-(@selector_bars[@next_country].x / 3.0))

        @selector_bars[@next_country].draw()

        @buttons.each { |button| button.draw() }

        # GUI
        Gosu.draw_rect($game.settings.default_width - 420,
                       0,
                       420,
                       $game.settings.default_height,
                       Gosu::Color.new(220, 0, 0, 0),
                       500)

        $font.draw(@selector_bars[@next_country].current_element,
                   $game.settings.default_width - 420,
                   10,
                   500,
                   0.4,
                   0.4,
                   Gosu::Color::YELLOW)

        spec_y = 80
        @specs[@selector_bars[@next_country].current_element].each do |key, spec|

            next if key[0] == "_"

            $font.draw("#{key} : #{spec}",
                $game.settings.default_width - 420,
                spec_y,
                500,
                0.3,
                0.35)

            spec_y += 22
        end

        $font.draw("Press enter to begin...",
                   $game.settings.default_width - 400,
                   $game.settings.default_height - 50,
                   500,
                   0.25,
                   0.30)
    end

    def reset
        @just_entered = true
        @next_state = nil
        @selector_bars.each { |_, sb| sb.reset }
    end

    def set_volume; end

    def set_country(c)
        @next_country = c
    end

end