require 'sinatra'
require 'haml'
require 'json'
load 'main.rb'

helpers do
  def js_files
    Dir["public/javascripts/**/*.js"].reject { |x| x =~ /views/ }.sort_by do |f|
      if f =~ /jquery/
        [0,f]
      elsif f =~ /vendor/
        [1,f]
      elsif f =~ /startup/
        [1.5,f]
      elsif f =~ /util/
        [2,f]
      elsif f =~ /models/
        [3,f]
      else
        [4,f]
      end
    end.map { |x| x.gsub("public/","") }
  end
  def css_files
    Dir["public/stylesheets/**/*.css"].map { |x| x.gsub("public/","") }
  end
  def views
    Dir["public/javascripts/views/*"].inject({}) do |h,f|
      str = File.read(f)
      name = File.basename(f).split(".").first
      h.merge(name => str)
    end
  end
end

get "/" do
  haml :index
end