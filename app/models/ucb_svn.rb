# On moving/renaming repos: http://svnbook.red-bean.com/en/1.5/svn.reposadmin.maint.moving-and-removing.html
# If we ever copy, backup, or "soft delete" need to manage UUID:
# http://svnbook.red-bean.com/en/1.5/svn.reposadmin.maint.html#svn.reposadmin.maint.uuids
class UcbSvn
  ##
  # Gets the root path of our repositories for a given environment.  For
  # example, in 'development' or 'test' mode the root will be:
  # "<Rails.root>/var/repos/<Rails.env>"
  #
  # In 'production' or 'quality_assurance' the root will be: "/home/svn/"
  #
  # @return [Pathname] root path of our repositories.
  #
  def self.root
    Pathname.new(AppConfig.svn_root)
  end
  UcbSvn.instance_eval { alias :root_path :root }
  
  
  ##
  # Gets the root path of our spaces: "<root>/spaces"
  #
  # @return [String] root path of our spaces.
  #
  def self.space_root()
    root.join(root, 'spaces')
  end
  UcbSvn.instance_eval { alias :space_root_path :space_root }
  
  ##
  # Gets the absolute path of a repository on the filesystem.
  #
  # @param [String] name of the space.
  # @param [String] name of the repo within the space.
  # @return [String] absolute path of the repository.
  #
  def self.repository_dir(space_name, repo_name)
    space_dir(space_name).join(repo_name)
  end
  UcbSvn.instance_eval { alias :repository_path :repository_dir }

  ##
  # Gets absolute path of the named space.
  #
  # @param [String] space name
  # @return [String] absolute path of the space.
  #    
  def self.space_dir(space_name)
    space_root.join(space_name)
  end
  UcbSvn.instance_eval { alias :space_path :space_dir }

  ##
  # The absolute path for an authz file for a repository.
  #
  # @param [String] space name
  # @param [String] repo name
  # @return [String] absolute path of the repository's authz file.
  #
  def self.repository_authz_file(space_name, repo_name)
    "#{repository_dir(space_name, repo_name)}/conf/authz"
  end

  ##
  # Create a space.
  #
  # @param [String] name of space (directory) to create.
  # @return [nil]
  #
  def self.create_space(space_name)
    dir = space_dir(space_name)
    FileUtils.mkdir_p(dir)
    call_os_cmd("chmod -R 0770 #{dir}")
    # TODO
    # FileUtils.chmod doesn't seem to work, find out why
    # FileUtils.chmod_R(0770, dir)
  end
  
  ##
  # Delete a space.
  #
  # @param [String] name of space (directory) to delete.
  # @return [nil]
  #    
  def self.delete_space(space_name)
    dir = space_dir(space_name)
    FileUtils.rm_rf(dir) if File.exists?(dir)
  end
  
  ##
  # Rename a space.
  #
  # @param [String] old space name
  # @param [String] edit space name
  # @return [nil]
  #    
  def self.rename_space(old_space_name, new_space_name)
    old_space_dir = space_dir(old_space_name)
    new_space_dir = space_dir(new_space_name)
    FileUtils.mv(old_space_dir, new_space_dir)
  end
  
  ##
  # Create an SVN repository within a given space.
  #
  # @param [String] name of space in which to create the repository.
  # @param [String] name of the repository to create.
  # @return [nil]
  #    
  def self.create_repository(space_name, repo_name)
    create_space(space_name) unless File.exists?(space_dir(space_name))

    dir = repository_dir(space_name, repo_name)
    unless File.exists?(dir)
      call_os_cmd("svnadmin create #{dir}")
      call_os_cmd("svn mkdir file://#{dir}/{trunk,tags,branches} -m 'init #{repo_name}'")      
      call_os_cmd("chgrp -R #{AppConfig.app_group} #{dir}")
      call_os_cmd("chmod -R 0770 #{dir}")
    end

    # TODO
    # FileUtils.chmod doesn't seem to work, find out why
    # FileUtils.chmod_R(0770, dir)

    initialize_svnserve_conf_file(space_name, repo_name)
    initialize_authz_file(space_name, repo_name)
    initialize_post_commit_hook_file(space_name, repo_name)
  end

  ##
  # Delete an SVN repository within a space.
  #
  # @param [String] name of space.
  # @param [String] name of repository.
  # @return [nil]
  #    
  def self.delete_repository(space_name, repo_name)
    dir = repository_dir(space_name, repo_name)
    FileUtils.rm_rf(dir) if File.exists?(dir)
  end

  ##
  # @param [String] name of space.
  # @param [String] name of repository.
  # @param [String] location to store archive
  # @return [nil]
  #
  def self.archive_repository(space_name, repo_name, archive_dir)
    dir = repository_dir(space_name, repo_name)
    archive = "#{archive_dir}/#{space_name}_#{repo_name}_#{archive_timestamp()}"
    FileUtils.mkdir(archive_dir) unless File.exists?(archive_dir)

    if File.exists?(dir)
      FileUtils.mv(dir, archive)
    else
      Rails.logger.warn("SVN Repository does not exist [#{dir}], archive failed.")
    end
  end

  def self.archive_timestamp()
    Time.now.strftime('%Y-%m-%d_%H-%M-%S')
  end

  ##
  # Rename an SVN repository within a space.
  #
  # @param [String] name of space.
  # @param [String] old repository name.
  # @param [String] edit repository name.
  # @return [nil]
  #    
  def self.rename_repository(space_name, old_repo_name, new_repo_name)
    old_repo_dir = repository_dir(space_name, old_repo_name).to_s
    new_repo_dir = repository_dir(space_name, new_repo_name).to_s
    FileUtils.mv(old_repo_dir, new_repo_dir)
  end
  
  ##
  # Move an SVN repository to a different space.
  #
  # @param [String] name of repository.
  # @param [String] name of old space.
  # @param [String] name of edit space.
  # @return [nil]
  #    
  def self.move_repository(repo_name, old_space_name, new_space_name)
    old_repo_dir = repository_dir(old_space_name, repo_name).to_s
    new_repo_dir = repository_dir(new_space_name, repo_name).to_s
    FileUtils.mv(old_repo_dir, new_repo_dir)
  end

  ##
  # List the files and or directories within a given repository
  #
  # @param [String] name of space.
  # @param [String] name of repository.
  # @return [Array<String>] directories and or files directly beneath the path
  #    
  def self.ls(space_name, repo_name, path = "/")
    # dir = File.join(self.repository_dir(space_name, repo_name),  path)
    dir = self.repository_dir(space_name, repo_name)
    ouput = call_os_cmd("svn ls file://#{dir}")[1]
    ouput.split("\n").map(&:strip)
  end
  
  
  ### TODO: Remaning methods should be private? ###

  
  ##
  # Initialize the SVN repository's' authz file so that it is NOT accessible
  # by anyone.  File in question is <repo_name>/conf/authz
  #
  # @param [String] name of space.
  # @param [String] name of repository.
  # @return [nil]
  #    
  def self.initialize_authz_file(space_name, repo_name)
    write_repository_authz_file(space_name, repo_name, Repository.authz_preamble())
  end
  
  ##
  # Initialize the SVN repository svnserve.conf file so that it uses our authz
  # file for authorization.
  #
  # @param [String] name of space.
  # @param [String] name of repoistory.
  # @return [nil]
  #    
  def self.initialize_svnserve_conf_file(space_name, repo_name)
    conf_file = "#{repository_dir(space_name, repo_name)}/conf/svnserve.conf"
    content = File.readlines(conf_file).map { |l|
      (l =~ /authz-db = authz/) ? "authz-db = authz" : l.strip
    }.join("\n")

    File.open(conf_file, "w") { |f| f.puts content }
    call_os_cmd("chgrp -R #{AppConfig.app_group} #{conf_file}")
    call_os_cmd("chmod -R 0770 #{conf_file}")
  end
  
  ##
  # Initialize the post_commit_hook file.  NOTE, this hook is used to tell
  # the application to update the cache (calculation of disk used) for a given
  # space after each commit.
  #
  # @param [String] name of space.
  # @param [String] name of repoistory.
  # @return [nil]
  #    
  def self.initialize_post_commit_hook_file(space_name, repo_name)
    hook_file = "#{repository_dir(space_name, repo_name)}/hooks/post-commit"
    File.open(hook_file, 'w') do |file|
      file.puts(post_commit_hook_contents(space_name, repo_name))
    end

    call_os_cmd("chgrp -R #{AppConfig.app_group} #{hook_file}")
    call_os_cmd("chmod -R 0770 #{hook_file}")
  end

  def self.post_commit_hook_contents(space_name, repo_name)
    port = (Rails.env.development? || Rails.env.test?) ? 3000 : 8080
    curl = `which curl`.chomp
    "#!/bin/sh \n\n #{curl} http://localhost:#{port}/api/repository_stats/calc_disk_usage/#{space_name}/#{repo_name}"
  end

  ##
  # Replace the contents of the authz file for a given space/repo
  #
  # @param [String] name of space.
  # @param [String] name of repoistory.
  # @param [String] edit content for authz file.
  # @return [nil]
  #    
  def self.write_repository_authz_file(space_name, repo_name, content)
    file = "#{repository_dir(space_name, repo_name)}/conf/authz"
    Rails.logger.debug("Writing authz file : #{file}")

    File.open(file, "w") do |f|
      f.flock(File::LOCK_EX)
      f.puts(content)
      f.flock(File::LOCK_UN)
    end
  end
  
  def self.call_os_cmd(cmd)
    App.call_os_cmd(cmd)
  end
  
  def self.logger()
    Rails.logger()
  end
end
