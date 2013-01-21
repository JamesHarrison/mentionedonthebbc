namespace :mentions do
  desc 'Update mentions forever'
  task :update => :environment do
    while(true)
      begin
        puts "Running update of mentions"
        Channel.each do |c|
          puts "Updating #{c.name}"
          c.add_new_mentions(Time.now-5.minutes, Time.now)
        end
        sleep 290
      rescue Exception => e
        puts "Got exception: #{e.inspect} #{e.to_s}"
        puts "Waiting 10s then retrying"
        sleep 10
        retry
      end
    end
  end
end
