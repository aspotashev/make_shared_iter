#!/usr/bin/ruby19
# Demo.
# Demotivating toy

require 'lib/make_shared_iter'

class My
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

  def cubes
    each_number do |n|
      puts n**3
    end
  end

  #===============================

  extend MakeSharedIterator

  make_shared_iterator :do_it,
    :methods => [:squares, :powers],
    :for => :each_number
  make_shared_iterator :do_powers,
    :methods => [:squares, :cubes],
    :for => :each_number
end

m = My.new
m.do_it
m.squares
m.do_it
m.do_powers

n = My.new
n.do_it
