module SpriteManager

    def SpriteManager.initialize
        @@sprites ||= {}
    end

    # Add sprite
    def SpriteManager.add(name, path)
        @@sprites[name] ||= {path: path,
                             image: Gosu::Image.new(path)}
    end

    # Get sprite (image)
    def SpriteManager.get_image(name)
        return @@sprites[name][:image]
    end

    # Get path
    def SpriteManager.get_path(name)
        return @@sprites[name][:path]
    end

end