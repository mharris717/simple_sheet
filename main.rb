require 'mharris_ext'
def generate_coffee_inner!(source)
  target = source.gsub(".coffee",".js").gsub("javascripts","javascripts/generated")
  require 'fileutils'
  FileUtils.mkdir_p(File.dirname(target))

  body = File.read(source)
  body = body.gsub(/@\$(\w+)/) do |str| 
    var = str[2..-1]
    "@get('#{var}')"
  end
  body = body.gsub(/\.\$(\w+)/) do |str| 
    var = str[2..-1]
    ".get('#{var}')"
  end

  temp = "c:/windows/temp/parsed_coffee.coffee"
  File.create(temp,body)

  cmd = "C:\\code\\CoffeeScript-Compiler-for-Windows\\coffee.bat #{temp} #{target}"
  puts cmd
  puts `#{cmd}`
end

def generate_coffee!(source)
  generate_coffee_inner!(source)
rescue => exp
  puts exp.message
end