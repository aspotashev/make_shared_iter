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
    each_number("hello") do |n|
      puts n**2
    end
  end

  def powers
    each_number("hello2") do |n|
      puts 2**n
    end
  end

  #===============================

  extend MakeSharedIterator

  make_shared_iterator :do_it,
    :methods => [:squares, :powers],
    :for => :each_number
end

My.new.do_it

