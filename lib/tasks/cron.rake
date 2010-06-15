task :cron do
  puts "Running cron at #{Time.now}"

  %w(twitter:update email:update aggregates:update).each do |task|
    begin
      puts "-----------#{'-'*task.size}"
      puts "Performing #{task}"
      Rake::Task[task].invoke
      puts
      puts
    rescue => e
      puts "Caught error running #{task}: #{e.inspect}"
    end
  end
end