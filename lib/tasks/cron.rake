task :cron do
  puts "Performing Twitter updates"
  Rake::Task['twitter:update'].invoke
  puts "Performing Email updates"
  Rake::Task['email:update'].invoke
  puts "Performing Aggregate updates"
  Rake::Task['aggregates:upate'].invoke
end