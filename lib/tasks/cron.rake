task :cron do
  Rake::Task['twitter:update'].invoke
  #Rake::Task['email:update'].invoke
end