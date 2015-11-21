#!/usr/bin/env ruby

# file: gtk2svg.rb

require 'gtk2'
require 'dom_render'


# Description: Experimental gem to render SVG within an GTK2 application. 
#           Currently it can only render rectangles along with the fill colour.


module SVG
  class Element

    attr_reader :style

    def initialize(attributes, style)

      @h = {x: '0', y: '0'}.merge attributes 

      @style = {fill: 'black'}
      @style.merge!(style) if attributes[:style]

    end

    def attributes()
      @h
    end

  end
end

module Gtk2SVG

  class Render < DomRender

    def svg(x, attributes, style)
      [:window, render_all(x)]
    end
    
    def ellipse(e, attributes, style)

      e2 = SVG::Element.new attributes, style
      h = e2.attributes
      style = e2.style


      x, y= %i(cx cy).map{|x| h[x].to_i }
      width = h[:rx].to_i * 2
      height = h[:ry].to_i * 2

      [:draw_arc, [x, y, width, height], style, render_all(e)]
    end    
    
    def line(e, attributes, style)

      e2 = SVG::Element.new attributes, style
      h = e2.attributes
      style = e2.style
      style[:stroke_width] = style.delete(:'stroke-width') || '3'

      x1, y1, x2, y2 = %i(x y x2 y2).map{|x| h[x].to_i }

      [:draw_line, [x1, y1, x2, y2], style, render_all(e)]
    end    

    def rect(e, attributes, style)

      e2 = SVG::Element.new attributes, style
      h = e2.attributes
      style = e2.style


      x1, y1, width, height = %i(x y width height).map{|x| h[x].to_i }
      x2, y2, = x1 + width, y1 + height

      [:draw_rectangle, [x1, y1, x2, y2], style, render_all(e)]
    end
    
    def text(e, attributes, style)

      e2 = SVG::Element.new attributes, style
      h = e2.attributes
      style = e2.style.merge({font_size: '20'})


      x, y, fill = %i(x y fill).map{|x| h[x] }
      style.merge!({fill: fill})

      [:draw_layout, [x.to_i, y.to_i], e.text, style, render_all(e)]
    end    

  end

  class DrawingInstructions

    attr_accessor :area


    def initialize(area=nil)

      @area = area if area

    end
    
    def draw_arc(args)

      dimensions, style = args

      x, y, width, height = dimensions
      gc = gc_ini(fill: style[:fill] || :none)
      @area.window.draw_arc(gc, 1, x, y, width, height, 0, 64 * 360)
    end    
    
    def draw_line(args)

      coords, style = args

      x1, y1, x2, y2 = coords
      gc = gc_ini(stroke: style[:stroke] || :none)
      gc.set_line_attributes(style[:stroke_width].to_i, Gdk::GC::LINE_SOLID, \
                                    Gdk::GC::CAP_NOT_LAST, Gdk::GC::JOIN_MITER)
      @area.window.draw_line(gc, x1, y1, x2, y2)
    end    

    def draw_rectangle(args)

      coords, style = args

      x1, y1, x2, y2 = coords
      gc = gc_ini(fill: style[:fill] || :none)
      @area.window.draw_rectangle(gc, 1, x1, y1, x2, y2)
    end
    
    def draw_layout(args)

      coords, text, style = args

      x, y = coords
      
      
      layout = Pango::Layout.new(Gdk::Pango.context)
      layout.font_description = Pango::FontDescription.\
                                             new('Sans ' + style[:font_size])      
      layout.text = text
            
      gc = gc_ini(fill: style[:fill] || :none)
      @area.window.draw_layout(gc, x, y, layout)
    end    

    def window(args)
    end

    def render(a)
      draw a
    end

    private

    def draw(a)

      a.each do |rawx|

        x, *remaining = rawx

        if x.is_a? Symbol then
          method(x).call(args=remaining)
        elsif x.is_a? String then
          draw remaining
        elsif x.is_a? Array
          draw remaining
        else        
          method(x).call(remaining.take 2)
        end
        
      end

    end

    def set_colour(fill)

      colour = case fill
      when /^rgb/
        regex = /rgb\((\d{1,3}), *(\d{1,3}), *(\d{1,3})\)$/
        r, g, b = fill.match(regex).captures.map {|x| x.to_i * 257}
        colour = Gdk::Color.new(r, g, b)
      when /^#/
          Gdk::Color.parse(fill)
      else
          Gdk::Color.parse(fill)
      end
      
      colormap = Gdk::Colormap.system
      colormap.alloc_color(colour,   false, true)

      colour
    end

    def gc_ini(fill: nil, stroke: nil)
      gc = Gdk::GC.new(area.window)
      colour = fill || stroke
      gc.set_foreground(set_colour(colour)) unless colour == :none
      gc
    end


  end
end



if __FILE__ == $0 then

  # Read an SVG file
  s = File.read(ARGV[0])

  area = Gtk::DrawingArea.new

  area.signal_connect("expose_event") do

    drawing = Gtk2SVG::DrawingInstructions.new area
    drawing.render Gtk2SVG::Render.new(s).to_a

  end

  Gtk::Window.new.add(area).show_all
  Gtk.main

end
