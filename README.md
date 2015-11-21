# Experimenting with creating an SVG app using the Gtk2SVG gem


    #!/usr/bin/env ruby

    # file: draw3.rb

    require 'gtk2svg'

    s =<<SVG
    <svg width="400" height="110">
      <rect width="300" height="100" style="fill:rgb(0,0,255);stroke-width:3;stroke:rgb(0,0,0)" />
      <rect x="100" y="100" width="100" height="100" style="fill:rgb(255,0,0);stroke-width:3;stroke:rgb(0,0,0)" />
    </svg>
    SVG

    a = Gtk2SVG::Render.new(s).to_a

    area = Gtk::DrawingArea.new

    area.signal_connect("expose_event") do

      drawing = Gtk2SVG::DrawingInstructions.new area
      drawing.render a

    end

    Gtk::Window.new.add(area).show_all
    Gtk.main

The above example creates a GTK2 application which can parse and render SVG. Below is a screenshot of the application.

![Screenshot of the SVG rendered in a GTK2 application](http://www.jamesrobertson.eu/r/images/2015/nov/21/screenshot-of-the-gtk2svg-app.png)

## Resources

* gtk2svg https://rubygems.org/gems/gtk2svg
* SVG Examples http://www.w3schools.com/svg/svg_examples.asp
* Drawing a rectangle using Ruby-gnome2 http://www.jamesrobertson.eu/snippets/2015/aug/30/drawing-a-rectangle-using-ruby-gnome2.html
* Drawing an ellipsis in Ruby-gnome2 http://www.jamesrobertson.eu/snippets/2015/aug/30/drawing-an-ellipsis-in-ruby-gnome2.html

gtk2 drawing svg gtk2svg gem

