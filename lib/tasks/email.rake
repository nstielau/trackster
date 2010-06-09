namespace :email do
  desc "Updates tracks from emails"
  task :update  => :environment do
    Mailman.read_emails
  end
end
