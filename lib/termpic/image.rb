module Termpic
  class Image
    def initialize(path, options = {})
      @image = Magick::ImageList.new(path)
      @fit_terminal = !!options[:fit_terminal]
      @show_size = !!options[:show_size]
    end

    def draw
      convert_to_fit_terminal_size if @fit_terminal
      rgb_analyze
      ansi_analyze
      puts_ansi
      puts_size if @show_size
    end

    def convert_to_fit_terminal_size
      term_height, term_width = get_term_size
      @image = @image.resize_to_fit(term_width / 2, term_height)
    end

    def rgb_analyze
      @rgb = []
      cols = @image.columns
      rows = @image.rows
      rows.times do |y|
        cols.times do |x|
          @rgb[y] ||= []
          pixcel = @image.pixel_color(x, y)
          r = pixcel.red / 256
          g = pixcel.green / 256
          b = pixcel.blue / 256
          @rgb[y] << [r, g, b]
        end
      end
    end

    def ansi_analyze
      raise "use rgb_analyze before ansi_analyze" unless @rgb
      ret = []
      @rgb.map! do |row|
        ret << row.map{|pixcel|
          r, g, b = pixcel
          "  ".background(r, g, b)
        }.join
      end
      @ansi = ret.join("\n")
    end

    def puts_ansi
      raise "use ansi_analyze before to_ansi" unless @ansi
      puts @ansi
    end

    def puts_size
      puts "#{@image.columns}x#{@image.rows}"
    end

    def get_term_size
      `stty size`.split(" ").map(&:to_i)
    end
  end
end

