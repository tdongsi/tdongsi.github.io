module Jekyll
  class Youtube < Liquid::Tag
    @width = 640
    @height = 390

    def initialize(name, id, tokens)
      super
      @id = id
    end

    def render(context)
      %(<iframe width="640" height="480" src="http://www.youtube.com/embed/#{@id}" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>)
    end
  end
end

Liquid::Template.register_tag('youtube', Jekyll::Youtube)