require 'bundler'
Bundler.require

image = "#{ENV['HOME']}/Desktop/Not Backed Up/OS/VBox Images/Ubuntu64Base.ova"
hosts = {
  :master => {
    :name => "MySQLMaster"
  },
  :slave => {
    :name => "MySQLSlave"
  }
}

desc 'Runs all the ops to bring up the replica set'
task :up => [:import, :bridge, :start, :prep, :cook]

desc 'Destroys the replica set'
task :down => [:stop, :destroy]

desc 'Imports the replica set VMs'
task :import do
  hosts.each do |type, host|
    next if host[:vm] = VirtualBox::VM.find(host[:name])
    host[:vm] = VirtualBox::VM.import(image) do |progress|
      print "Importing #{host[:name]}: #{progress.percent}%\r"
    end
    puts "Importing #{host[:name]}: 100%"
    host[:vm].name = host[:name]
    host[:vm].network_adapters[0].mac_address = nil
    host[:vm].save
  end
end

desc 'Bridges the VMs NIC to default interface'
task :bridge => :import do
  # Can't find gem equivalent
  default = `VBoxManage list bridgedifs`.match(/^Name:\s+(.*)$/)[1]
  hosts.each do |type, host|
    next if host[:vm].running?
    host[:vm].network_adapters[0].host_interface = default
    host[:vm].network_adapters[0].attachment_type = :bridged
    host[:vm].save
  end
end

desc 'Starts the replica set'
task :start => :bridge do
  hosts.each do |type, host|
    host[:vm].start(:headless)
  end
end

desc 'Prepares the VMs for chef'
task :prepare => :start do
  hosts.each do |type, host|
    host[:ip] = host[:vm].interface.get_guest_property_value("/VirtualBox/GuestInfo/Net/0/V4/IP")
    p host[:ip]
  end
end

desc 'Stops the replica set'
task :stop do
  hosts.each do |type, host|
    host[:vm] = VirtualBox::VM.find(host[:name])
    host[:vm].start(:headless)
  end
end

desc 'Destroys the replica set VMs'
task :destroy => :stop do
  hosts.each do |type, host|
    host[:vm].destroy(:destroy_medium => true)
  end
end

