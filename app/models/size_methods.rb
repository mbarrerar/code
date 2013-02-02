module SizeMethods
  module ClassMethods
  end

  module InstanceMethods
    def size_display
      App.number_to_human_size(actual_size)
    end

    # Set actual size. "du -sk" returns number of 1024 byte blocks.
    def update_size(opts = {})
      disk_usage = `du -sk #{svn_dir}`.split(/\s/).first.to_i * 1024
      self.class.update_all("actual_size = #{disk_usage}", "id = #{id}") # don't retrigger callbacks
      opts[:format] ? App.number_to_human_size(disk_usage) : disk_usage
    end

    alias :calc_disk_usage :update_size
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end
