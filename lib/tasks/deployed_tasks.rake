# lib/tasks/deployed.rake

namespace :deployed do
  desc "Execute a Kamal command and log its output"
  task :execute_and_log, [:command] => :environment do |task, args|
    command = args[:command]

    unless command
      puts "Please provide a Kamal command. Usage: rake deployed:execute_and_log[command]"
      next
    end

    log_file = Rails.root.join(Deployed::DIRECTORY, 'deployments/current.log')

    File.open(log_file, 'a') do |file|
      IO.popen("kamal #{command}") do |io|
        start_time = Time.now

        file.puts("[Deployed] > kamal #{command}")
        file.fsync

        io.each_line do |line|
          file.puts line
          file.fsync  # Force data to be written to disk immediately
        end
        end_time = Time.now
        file.puts("[Deployed] Finished in #{end_time - start_time} seconds")
        file.puts("[Deployed] End")
        file.fsync

        # Delete lockfile
        File.delete(Rails.root.join(Deployed::DIRECTORY, 'process.lock'))
      end
    end
  end
end
