require 'json'

module LicenseFinder
  class Cargo < PackageManager
    def current_packages
      cargo_output.map do |package|
        CargoPackage.new(package, logger: logger)
      end
    end

    def self.package_management_command
      'cargo'
    end

    def self.prepare_command
      'cargo fetch'
    end

    def possible_package_paths
      [project_path.join('Cargo.lock'), project_path.join('Cargo.toml')]
    end

    private

    def cargo_output
      command = "#{Cargo.package_management_command} metadata --format-version=1"

      stdout, stderr, status = Dir.chdir(project_path) { Cmd.run(command) }
      raise "Command '#{command}' failed to execute: #{stderr}" unless status.success?
      JSON(stdout)
        .fetch('packages', [])
    end
  end
end
