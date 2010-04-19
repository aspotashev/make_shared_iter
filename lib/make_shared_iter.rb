
module MakeSharedIterator
  def make_shared_iterator(new_method,options)
    raise if not options[:for] or not options[:methods]

    (self.is_a?(Module) ? self : self.singleton_class).class_eval do
      alias_method "#{options[:for]}_orig", options[:for]

      define_method(options[:for].to_sym) do |*args,&block|
        loop do
          block[Fiber.yield]
        end
      end

      define_method(new_method) do
        fibers = options[:methods].map {|m| Fiber.new { send m } }
        fibers.each(&:resume)

        method("#{options[:for]}_orig".to_sym).call do |n|
          fibers.each {|f| f.resume(n) }
        end
      end
    end
  end
end

