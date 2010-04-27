$:.unshift(File.dirname(__FILE__))
$:.unshift(File.join(File.dirname(__FILE__), ".."))
$:.unshift(File.join(File.dirname(__FILE__), "..", 'lib'))

require 'make_shared_iter'

require 'test/unit'

class TestSimple < Test::Unit::TestCase
  class A

    include MakeSharedIterator

    class <<self
      attr_accessor :ary
    end

    def each_object(&block)
      (1..3).each(&block)
    end

    def a
      each_object do |i|
        self.class.ary << 0   
      end
    end

    def b
      each_object do |i|
        self.class.ary << i   
      end
    end

    def c
      each_object do |i|
        self.class.ary << i*i   
      end
    end

    make_shared_iterator :do_ab,
      :methods => [:a, :b],
      :for => :each_object

    make_shared_iterator :do_abc,
      :methods => [:a, :b, :c], 
      :for => :each_object
  end

  #def initialize(method)
  #  A.ary = []
  #  method
  #end

  def test_ab
    A.ary = []
    A.new.do_ab
    #p A.ary
    assert_equal([0,1,0,2,0,3], A.ary)   
  end

  def test_abc
    A.ary = []
    A.new.do_abc
    #p A.ary
    assert_equal([0,1,1,0,2,4,0,3,9], A.ary)   
  end


end

