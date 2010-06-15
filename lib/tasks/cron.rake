task :cron do
  puts "Running cron at #{Time.now}"

  %w(twitter:update email:update aggregates:update).each do |task|
    begin
      puts "-----------#{'-'*task.size}"
      puts "Performing #{task}"
      Rake::Task[task].invoke
    rescue => e
      puts "Caught error running #{task}: #{e.inspect}"
    ensure
      puts
      puts
    end
  end
end