require 'rubygems'
require 'rake'

desc "Mogenerate subclasses"
task :mogenerate do
  output = `mogenerator -m Punto/Models/Punto.xcdatamodeld/Punto.xcdatamodel -O Punto/Models --template-var arc=true`
  puts "I mogenerated: #{output}"
end
