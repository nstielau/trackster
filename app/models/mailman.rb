require 'gmail'
require 'uri'

class Mailman
  def self.read_emails
    Gmail.new(TRACKSTER_GMAIL_USERNAME, TRACKSTER_GMAIL_PASSWORD) do |gmail|
      inbox_count = gmail.inbox.count
      puts "There are #{inbox_count} emails in the inbox"
      gmail.inbox.emails(:from => "no-reply@motionx.com").each do |email|
        puts "Email: #{email.inspect}"

        # save attachements
        gpx_attachment = email.attachments.select{|a| a.filename.match("gpx")}.first
        tmp_gpx_file = File.new(File.join(Dir.tmpdir, "track_#{Time.now.to_i}.gpx"), File::CREAT|File::RDWR)
        tmp_gpx_file << gpx_attachment.read

        kmz_attachment = email.attachments.select{|a| a.filename.match("kmz")}.first
        tmp_kmz_file = File.new(File.join(Dir.tmpdir, "track_#{Time.now.to_i}.kmz"), File::CREAT|File::RDWR)
        tmp_kmz_file << kmz_attachment.read

        # Create track
        track = Track.new(:kmz_file => tmp_kmz_file, :gpx_file => tmp_gpx_file)
        track.save
        track.update_from_kmz!
        puts "Track: #{track.inspect}"

        # Clean up tmp files
        tmp_gpx_file.close
        File.delete(tmp_gpx_file.path)
        tmp_kmz_file.close
        File.delete(tmp_kmz_file.path)

        email.archive!
      end
    end
  end
end