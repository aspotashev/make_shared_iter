require 'fiber'
require 'lib/meta_ext'

module MakeSharedIterator
  def make_shared_iterator(new_method,options)
    raise if not options[:for] or not options[:methods]

    (self.is_a?(Module) ? self : self.singleton_class).class_eval do
      @@iter_sharing_fibers ||= {}
      @@iter_sharing_patched_methods ||= Hash.new(0)
      @@iter_sharing_lock ||= Mutex.new

      define_method("#{options[:for]}_patched") do |*args,&block|
        if @@iter_sharing_fibers.has_key?(Fiber.current.object_id)
          loop do
            block[Fiber.yield]
          end
        else
          send "#{options[:for]}_orig", *args, &block
        end
      end

      define_method(new_method) do
        @@iter_sharing_lock.synchronize do
          if @@iter_sharing_patched_methods[options[:for]] == 0
            self.class.send :alias_method, "#{options[:for]}_orig", options[:for]
            self.class.send :alias_method, options[:for], "#{options[:for]}_patched"
          end
          @@iter_sharing_patched_methods[options[:for]] += 1
        end

        fibers = options[:methods].map {|m| Fiber.new { send m } }
        fibers.each {|f| @@iter_sharing_fibers[f.object_id] = true }
        fibers.each(&:resume)

        send "#{options[:for]}_orig".to_sym do |n|
          fibers.each {|f| f.resume(n) }
        end

        fibers.each {|f| @@iter_sharing_fibers.delete(f.object_id) }

        @@iter_sharing_lock.synchronize do
          if (@@iter_sharing_patched_methods[options[:for]] -= 1) == 0
            self.class.send :alias_method, options[:for], "#{options[:for]}_orig"
          end
        end
      end
    end
  end
end

