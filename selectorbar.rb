class SelectorBar

    attr_reader :current_image, :x, :moving

    def initialize(size, *paths)
        @size = size

        @spacing = 120
        @border = 3

        @names = []

        @current_image = 0

        @next_image = 0

        paths.each { |name| @names << name }

        @x = ($game.settings.default_width - @size) / 2
        @y = 0

        @next_x = @x

        @moving = false
    end

    def update
        if @next_image == @current_image

            @moving = false

            if button_down?(KB_RIGHT) && @current_image < @names.size - 1
                @next_image = @current_image + 1
                @next_x = @x - (@size + @spacing)
            elsif button_down?(KB_LEFT) && @current_image > 0
                @next_image = @current_image - 1
                @next_x = @x + (@size + @spacing)
            end
        else

            @moving = true

            if @next_x < @x
                @x -= 15
                
                if @next_x > @x
                    @x = @next_x
                    @current_image = @next_image
                end
            elsif @next_x > @x
                @x += 15
                
                if @next_x < @x
                    @x = @next_x
                    @current_image = @next_image
                end
            end
        end
    end

    def draw
        # Draw the selection square
        Gosu.draw_rect(($game.settings.default_width - @size * 1.2) / 2,
                       ($game.settings.default_height - @size * 1.2) / 2,
                       @size * 1.2,
                       @size * 1.2,
                       Color::YELLOW,
                       500)
    
        Gosu.draw_rect(($game.settings.default_width - @size * 1.2) / 2 + @border,
                       ($game.settings.default_height - @size * 1.2) / 2 + @border,
                       @size * 1.2 - @border * 2,
                       @size * 1.2 - @border * 2,
                       Color.new(220, 0, 0, 0),
                       500)

        # Draw spaceship
        i = 0
        @names.each do |name|
            SpriteManager.get_image(name).draw(@x + i * (@size + @spacing),
                ($game.settings.default_height - @size) / 2,
                500,
                @size / SpriteManager.get_image(name).width.to_f,
                @size / SpriteManager.get_image(name).width.to_f) if @x + i * (@size + @spacing) + @size > 0 and
                                                                     @x + i * (@size + @spacing) < $game.settings.default_width

            $font.draw(name,
                       @x + i * (@size + @spacing) + (@size - $font.text_width(name, 0.35))/2,
                       ($game.settings.default_height - @size) / 2 + @size + 25,
                       500,
                       0.35,
                       0.35)  

            i += 1
        end
    end

    def reset
        @x = ($game.settings.default_width - @size) / 2
        @y = 0

        @current_image = 0

        @next_image = 0

        @next_x = @x
    end

    def current_element
        return @names.to_a[@current_image]
    end

end