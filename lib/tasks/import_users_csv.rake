require "optparse"
namespace :users do
  desc "Import users from CSV file"
  namespace :import do
    task :csv, [ :file_path ] => :environment do |_t, rake_args|
      options = {}
      opts = OptionParser.new
      opts.banner = "Usage: rake users:import:csv -- [options] \nThe csv file should have headers!"
      opts.on("-f", "--file_path PATH", "Path to the CSV file") do |file_path|
        options[:file_path] = file_path
      end
      opts.raise_unknown = false
      args = opts.order!(ARGV) { }
      opts.parse!(args)

      file_path = rake_args[:file_path] ||
                  options[:file_path] ||
                  ENV["FILE_PATH"] ||
                  raise(ArgumentError, "Missing file path. Please provide a valid CSV file path using -f or --file_path option.")

      begin
        puts "Importing users from #{file_path}..."
        service = UserImporter.new(file_path)

        if service.call
          service.results[:successful].each do |user|
            puts "Created #{user[:type]}: #{user[:email]}"
          end
          puts "Import completed successfully."
        else
          service.results[:failed].each do |failure|
            puts "[X] Failed to create #{failure[:email]}: #{failure[:errors].join(', ')}"
          end
          puts "[X] Import rolled back: #{service.error_message}" if service.respond_to?(:error_message)
          exit(1)
        end
      rescue ArgumentError => e
        puts "[X] #{e.message}"
        exit(1)
      end
    end
  end
end
