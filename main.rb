require 'mharris_ext'
def generate_coffee_inner!(source)
  target = source.gsub(".coffee",".js").gsub("javascripts","javascripts/generated")
  require 'fileutils'
  FileUtils.mkdir_p(File.dirname(target))

  body = File.read(source)

  body = body.gsub(/@\$\$(\w+)/) do |str| 
    var = str[3..-1]
    "@safeGet('#{var}')"
  end
  body = body.gsub(/\.\$\$(\w+)/) do |str| 
    var = str[3..-1]
    ".safeGet('#{var}')"
  end
  body = body.gsub(/@\$(\w+)/) do |str| 
    var = str[2..-1]
    "@get('#{var}')"
  end
  body = body.gsub(/\.\$(\w+)/) do |str| 
    var = str[2..-1]
    ".get('#{var}')"
  end

  if source =~ /public\/javascript/i
    body = "app = window.App\n\n#{body}"
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

def generate_pegjs!(source)
  target = source.gsub(".pegjs",".js").gsub("javascripts","javascripts/generated")
  require 'fileutils'
  FileUtils.mkdir_p(File.dirname(target))

  body = File.read(source).strip

  body = body.gsub("\n","\\n\\\n")

  File.create(target,body)
end

def generate_coffee_all!
  require 'fileutils'
  Dir["**/generated/**/*.js"].each do |f|
    FileUtils.rm(f)
  end
  Dir["**/*.coffee"].each do |f|
    generate_coffee!(f)
  end
  Dir["**/*.pegjs"].each do |f|
    generate_pegjs!(f)
  end
end

#generate_coffee_all!