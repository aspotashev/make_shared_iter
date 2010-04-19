#!/usr/bin/ruby19

def each_number
  (1..5).each do |n|
    puts "number generated (#{n})"
    yield n
  end
end

def squares
  each_number do |n|
    puts n**2
  end
end

def powers
  each_number do |n|
    puts 2**n
  end
end

#==================================

alias each_number_orig each_number

def each_number
  loop do
    yield Fiber.yield
  end
end

def do_it
  sf = Fiber.new { squares }
  pf = Fiber.new { powers }

  sf.resume
  pf.resume

  each_number_orig do |n|
    sf.resume(n)
    pf.resume(n)
  end
end

do_it

