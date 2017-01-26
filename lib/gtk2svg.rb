#!/usr/bin/env ruby

# file: gtk2svg.rb

require 'gtk2'
require 'dom_render'
require 'svgle'

# Description: Experimental gem to render SVG within a GTK2 application. 


module Gtk2SVG

  class Render < DomRender


    def circle(e, attributes, raw_style)

      style = style_filter(attributes).merge(raw_style)

      h = attributes

      x, y= %i(cx cy).map{|x| h[x].to_i }
      radius = h[:r].to_i * 2

      [:draw_arc, [x, y, radius, radius], style, render_all(e)]
    end       
    
    def ellipse(e, attributes, raw_style)

      style = style_filter(attributes).merge(raw_style)
      h = attributes

      x, y= %i(cx cy).map{|x| h[x].to_i }
      width = h[:rx].to_i * 2
      height = h[:ry].to_i * 2

      [:draw_arc, [x, y, width, height], style, render_all(e)]
    end    
    
    def line(e, attributes, raw_style)

      style = style_filter(attributes).merge(raw_style)

      x1, y1, x2, y2 = %i(x1 y1 x2 y2).map{|x| attributes[x].to_i }

      [:draw_line, [x1, y1, x2, y2], style, render_all(e)]
    end   
    
    def image(e, attributes, raw_style)

      style = style_filter(attributes).merge(raw_style)
      h = attributes

      x, y, width, height = %i(x y width height).map{|x| h[x] ? h[x].to_i : nil }
      src = h[:'xlink:href']

      [:draw_image, [x, y, width, height], src, style, render_all(e)]
    end    

    def polygon(e, attributes, raw_style)

      style = style_filter(attributes).merge(raw_style)
      points = attributes[:points].split(/\s+/). \
                                       map {|x| x.split(/\s*,\s*/).map(&:to_i)}

      [:draw_polygon, points, style, render_all(e)]
    end

    def polyline(e, attributes, raw_style)

      style = style_filter(attributes).merge(raw_style)
      points = attributes[:points].split(/\s+/). \
                                       map {|x| x.split(/\s*,\s*/).map(&:to_i)}

      [:draw_lines, points, style, render_all(e)]
    end           

    def rect(e, attributes, raw_style)

      style = style_filter(attributes).merge(raw_style)
      h = attributes

      x1, y1, width, height = %i(x y width height).map{|x| h[x].to_i }
      x2, y2, = x1 + width, y1 + height

      [:draw_rectangle, [x1, y1, x2, y2], style, render_all(e)]
    end
    
    def script(e, attributes, style)
      [:script]
    end        
    
    def svg(e, attributes, raw_style)

      style = style_filter(attributes).merge(raw_style)
      
      # jr051216 style[:fill] = style.delete :'background-color'
      h = attributes
      width, height = %i(width height).map{|x| h[x].to_i }
      
      [:draw_rectangle, [0, 0, width, height], style, render_all(e)]
    end    
    
    def text(e, attributes, raw_style)

      style = style_filter(attributes).merge(raw_style)
      style.merge!({font_size: '20'})

      x, y = %i(x y).map{|x| attributes[x].to_i }

      [:draw_layout, [x, y], e.text, style, render_all(e)]
    end    
    
    private
    
    def style_filter(attributes)
      
      %i(stroke stroke-width fill).inject({}) do |r,x|
        attributes.has_key?(x) ? r.merge(x => attributes[x]) : r          
      end
      
    end

  end

  class DrawingInstructions

    attr_accessor :area


    def initialize(area=nil, window=nil)

      @area = area
      @window = window

    end
    
    def draw_arc(args)

      dimensions, style = args

      x, y, width, height = dimensions

      gc = gc_ini(fill: style[:fill] || :none)
      @area.window.draw_arc(gc, 1, x, y, width, height, 0, 64 * 360)
    end    
    
    def draw_image(args)

      dimensions, src, style = args

      x, y, width, height = dimensions

      gc = gc_ini(fill: style[:fill] || :none)
      img = GdkPixbuf::Pixbuf.new(file: src)
      
      x ||= 0
      y ||= 0
      width ||= img.width
      height ||= img.height
      
      @area.window.draw_pixbuf(gc, img, 0, 0, x, y, width, height, 
                               Gdk::RGB::DITHER_NONE, 0, 0)

    end      
    
    def draw_line(args)

      coords, style = args

      x1, y1, x2, y2 = coords

      gc = gc_ini(stroke: style[:stroke] || :none)
      gc.set_line_attributes(style[:'stroke-width'].to_i, Gdk::GC::LINE_SOLID, \
                                    Gdk::GC::CAP_NOT_LAST, Gdk::GC::JOIN_MITER)
      @area.window.draw_line(gc, x1, y1, x2, y2)
    end    
    
    def draw_polygon(args)

      points, style = args


      gc = gc_ini(fill: style[:fill] || :none, stroke: style[:stroke] || :none)
      gc.set_line_attributes(style[:'stroke-width'].to_i, Gdk::GC::LINE_SOLID, \
                                    Gdk::GC::CAP_NOT_LAST, Gdk::GC::JOIN_MITER)
      @area.window.draw_polygon(gc, 1, points)
    end       
    
    def draw_lines(args)

      points, style = args

      gc = gc_ini(fill: style[:fill] || :none, stroke: style[:stroke] || :none)
      gc.set_line_attributes(style[:'stroke-width'].to_i, Gdk::GC::LINE_SOLID, \
                                    Gdk::GC::CAP_NOT_LAST, Gdk::GC::JOIN_MITER)
      @area.window.draw_lines(gc, points)
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
                                             new('Sans ' + style[:'font-size'])
      layout.text = text.strip
            
      gc = gc_ini(fill: style[:fill] || :none)
      @area.window.draw_layout(gc, x, y, layout)
    end    

    def window(args)
    end

    def render(a)
      method(a[0]).call(args=a[1..2])
      draw a[3]
    end
    
    def script(args)

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

    def set_colour(c)

      colour = case c
      when /^rgb/
        regex = /rgb\((\d{1,3}), *(\d{1,3}), *(\d{1,3})\)$/
        r, g, b = c.match(regex).captures.map {|x| x.to_i * 257}
        colour = Gdk::Color.new(r, g, b)
      when /^#/
          Gdk::Color.parse(c)
      else
          Gdk::Color.parse(c)
      end
      
      colormap = Gdk::Colormap.system
      colormap.alloc_color(colour,   false, true)

      colour
    end

    def gc_ini(fill: nil, stroke: nil)
      gc = Gdk::GC.new(@area.window)
      colour = fill || stroke

      unless colour == :none or colour == 'none'
        gc.set_foreground(set_colour(colour)) 
      end
      
      gc
    end


  end
  
  class Main
    
    
    attr_accessor :doc, :svg
    attr_reader :width, :height
    
    def initialize(svg, irb: false)
      
      @svg = svg
      @doc = Svgle.new(svg, callback: self)

      @area = area = Gtk::DrawingArea.new
      
      doc = @doc
      
      def @doc.element_by_id(id)
        self.root.element("//*[@id='#{id}']")
      end            
      

      

      client_code = []
      
      window = Gtk::Window.new
      @width, @height = %i(width height).map{|x| @doc.root.attributes[x].to_i }
      
      if @width and @height then
        window.set_default_size(@width, @height)
      end
      
      @dirty = true
      
      @doc.root.xpath('//script').each {|x| eval x.text.unescape }

      x1 = 150      
      
      area.signal_connect("expose_event") do      
        y1 = 30; x2 = 200; y2 = 70
          area.window.draw_rectangle(area.style.fg_gc(area.state), 1, x1, y1, x2, y2)
        if @dirty then
          
          Thread.new { @doc.root.xpath('//script').each {|x| eval x.text.unescape } }

          @instructions = Gtk2SVG::Render.new(@doc).to_a
        end
        
        drawing = DrawingInstructions.new area
        drawing.render @instructions
        @dirty = false
        
      end
      
      area.add_events(Gdk::Event::POINTER_MOTION_MASK) 

      area.signal_connect('motion_notify_event') do |item,  event|

        @doc.root.xpath('//*[@onmousemove]').each do |x|
                    
          eval x.onmousemove() if x.hotspot? event.x, event.y
          
        end
      end

      area.add_events(Gdk::Event::BUTTON_PRESS_MASK) 

      area.signal_connect "button_press_event" do |item,event| 

        @doc.root.xpath('//*[@onmousedown]').each do |x|
                    
          eval x.onmousedown() if x.hotspot? event.x, event.y
          
        end        
      end      
      
      window.add(area).show_all

      Thread.new do
        @doc.root.xpath('//*[@onload]').each do |x|
                    
          eval x.onload()
          
        end
      end
      
      #Thread.new do
      #  3.times { x1 -= 1; @area.queue_draw; sleep 0.1}
      #end
      sleep 0.01
      #@area.queue_draw; sleep 0.01
      window.show_all.signal_connect("destroy"){Gtk.main_quit}

      irb ? Thread.new {Gtk.main  } : Gtk.main
    end
    
    def onmousemove(x,y)
      
    end    
    
    def svg=(svg)
      @svg = svg
      @doc = Svgle.new(svg, callback: self)
    end
    
    def timeout(duration, loopx=true)
      
      GLib::Timeout.add(duration) do 
        yield
        @area.queue_draw
        loopx
      end

    end
    
  end
end


if __FILE__ == $0 then

  # Read an SVG file
  svg = File.read(ARGV[0])

  app = Gtk2SVG::Main.new svg

end