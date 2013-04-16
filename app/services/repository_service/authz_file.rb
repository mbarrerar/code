module RepositoryService
  class AuthzFile

    PERMISSIONS = { :commit => 'rw', :read => 'r' }.freeze

    def initialize
      @entries = [preamble]
    end

    def append_committers(committers)
      committers.each { |committer| @entries << entry(committer.username, :commit) }
    end

    def append_readers(readers)
      readers.each { |reader| @entries << entry(reader.username, :read) }
    end

    def to_s
      @entries.flatten.uniq.join("\n")
    end

    private

    def entry(username, perm)
      "#{username} = #{permission(perm)}"
    end

    def permission(perm)
      PERMISSIONS.fetch(perm.to_sym)
    end

    def preamble
      ['# This file is generated by the code@berkeley application', '[/]'].join('\n')
    end

  end
end