require "./ecr/macros"
require "html"

class Builder  
  def nested(name, &block : Proc(Builder, IO, Nil))
    ->(io : IO) do
      io << "<nested type='#{name}'>"
      block.call(self, io)
      io << "</nested>"
    end
  end

  def input(name)
    "<input name='#{name}' />"
  end
end

def form(etc, name, &block : Proc(Builder, IO, Nil))
  ->(io : IO) do 
    io << "<form etc='#{etc}' name='#{name}'>"
    builder = Builder.new
    block.call(builder, io)
    io << "</form>"
  end
end

class HTMLEscapeIO < IO
  def initialize(@output : IO = IO::Memory.new); end
  
  def write(slice : Bytes) : Nil
    HTML.escape(slice, @output)
  end
  
  def read(slice : Bytes) : Int32
    @output.read(slice)
  end
  
  def to_s(io)
    @output.to_s(io)
  end
end

File.open("escape.log", "w") do |handle|
  escaped = HTMLEscapeIO.new(handle)
  ECR.embed "#{__DIR__}/template.ecr", escaped
end

puts "streamed escaped html to escape.log"

puts "unescaped\n"
puts ECR.render("#{__DIR__}/template.ecr")



