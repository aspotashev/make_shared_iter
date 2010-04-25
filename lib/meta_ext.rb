
class Object
  def singleton_class
    (class << self ; self ; end) rescue nil
  end
end

