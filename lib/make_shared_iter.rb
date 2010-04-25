require 'fiber'

module MakeSharedIterator
  def make_shared_iterator(new_method,options)
    raise if not options[:for] or not options[:methods]

    (self.is_a?(Module) ? self : self.singleton_class).class_eval do
      alias_method "#{options[:for]}_orig", options[:for]

      @@iter_sharing_fibers ||= {}

      define_method(options[:for].to_sym) do |*args,&block|
        if @@iter_sharing_fibers.has_key?(Fiber.current.object_id)
          loop do
            block[Fiber.yield]
          end
        else
          send "#{options[:for]}_orig", *args, &block
        end
      end

      define_method(new_method) do
        fibers = options[:methods].map {|m| Fiber.new { send m } }
        fibers.each {|f| @@iter_sharing_fibers[f.object_id] = true }
        fibers.each(&:resume)

        send "#{options[:for]}_orig".to_sym do |n|
          fibers.each {|f| f.resume(n) }
        end

        fibers.each {|f| @@iter_sharing_fibers.delete(f.object_id) }
      end
    end
  end
end

