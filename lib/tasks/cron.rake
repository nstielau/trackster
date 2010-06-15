task :cron do
  Rake::Task['twitter:update'].invoke
  Rake::Task['email:update'].invoke
  Rake::Task['aggregates:upate'].invoke
end