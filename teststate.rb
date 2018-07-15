class TestState

    def initialize
        @progress_bar = ProgressBar.new(250, 32, 100)
    end

    def update

    end

    def draw
        # Gosu.draw_rect(0, 0, $game.settings.default_width, $game.settings.default_height, Color::WHITE, 0)
        @progress_bar.draw
    end

    def reset

    end

    def set_volume; end

end