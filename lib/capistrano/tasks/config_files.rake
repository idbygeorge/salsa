# lib/capistrano/tasks/config_files.cap
#
# Capistrano task to upload configuration files outside SCM
# Jesus Burgos Macia
#
# This allows us to have server's config files isolated from development ones.
# That's useful for several reasons, but the most important is that you can
# ignore files from repository.
#
# The task will upload all files found in
#  - Local directory: config/deploy/config/[environment/]*.yml
# to all servers
#  - Server directory : config/*.yml
#
# Example:
#   [local]                                          [server:production]
#   config/deploy/config/production/database.yml ->  shared/config/database.yml
#   config/deploy/config/database.yml            ->  shared/config/database.yml
#   config/deploy/config/aws.yml                 ->  shared/config/aws.yml
#
# If two files with the same name are found in config/deploy/config/:stage/ and
# config/deploy/config, the stage-specific one will take priority.
#
namespace :deploy do
  desc 'Updates shared/config/*.yml files with the proper ones for environment'
  task :upload_shared_config_files do
    config_files = {}

    run_locally do
      # Order matters!
      local_config_directories = [
        "config/deploy/config/#{fetch(:stage)}",
        "config/deploy/config/default"
      ]

      # Environment specific files first
      local_config_directories.each do |directory|
        Dir.chdir(directory) do
          Dir.glob("*.yml") do |file_name|
            # Skip this file if we've already uploaded a env. specific one
            next if config_files.keys.include? file_name

            cksum = capture "cksum", File.join(Dir.pwd, file_name)
            config_files[file_name] = cksum
          end
        end
      end
    end

    on roles(:all) do
      config_path = File.join shared_path, "config"
      execute "mkdir -p #{config_path}"

      config_files.each do |file_name, local_cksum|
        remote_file_name = "#{config_path}/#{file_name}"

        # Get the
        lsum, lsize, lpath = local_cksum.split

        if test("[ -f #{remote_file_name} ]")
          remote_cksum = capture "cksum", remote_file_name
          rsum, rsize, rpath = remote_cksum.split

          if lsum != rsum
            upload! lpath, remote_file_name
            info "Replaced #{file_name} -> #{remote_file_name}"
          end
        else
          upload! lpath, remote_file_name
          info "Upload new #{file_name} -> #{remote_file_name}"
        end
      end
    end
  end

  before :check, :upload_shared_config_files
end
