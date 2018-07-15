class ProgressBar

    attr_accessor :width, :height, :percentage
    attr_accessor :position, :color, :border_color, :text_color
    attr_accessor :text

    def initialize(width, height, percentage)
        @width = width
        @height = height
        @percentage = percentage

        @position = Vec2.new(0, 0)

        @color = Color::RED
        @border_color = Color::WHITE
        @text_color = Color::BLACK

        @text = ""
    end

    def draw
        Gosu.draw_rect(@position.x,
                       @position.y,
                       @width + 4,
                       @height + 4,
                       @border_color,
                       500)

        Gosu.draw_rect(@position.x + 2,
                       @position.y + 2,
                       @percentage * @width / 100,
                       @height,
                       @color,
                       500)

        $font.draw(@text,
            @position.x + (@width - $font.text_width(@text, 0.25))/2,
            @position.y + (@height - $font.height * 0.25) / 2,
            500,
            0.25,
            0.25,
            @text_color)
    end
end