require 'bundler'
Bundler.require

run_mode = :gui
image = "#{ENV['HOME']}/Desktop/Not Backed Up/OS/VBox Images/Ubuntu64Base.ova"
cook = "#{ENV['HOME']}/code/littlechef/cook"
hosts = {
  :master => {
    :name => "MySQLMaster"
  },
  :slave => {
    :name => "MySQLSlave"
  }
}

desc 'Runs all the ops to bring up the replica set'
task :up => [:prep, :cook]

desc 'Destroys the replica set'
task :down => :destroy

desc 'Imports the replica set VMs'
task :import do
  hosts.each do |type, host|
    next if host[:vm] = VirtualBox::VM.find(host[:name])
    host[:vm] = VirtualBox::VM.import(image) do |progress|
      print "Importing #{host[:name]}: #{progress.percent}%\r"
    end
    puts "Importing #{host[:name]}: 100%"
    host[:vm].name = host[:name]
    host[:vm].network_adapters.each { |a| a.mac_address = nil }
    host[:vm].save
  end
end

desc 'Bridges the VMs NIC to default interface'
task :bridge => :import do
  # Can't find gem equivalent
  default = `VBoxManage list bridgedifs`.match(/^Name:\s+(.*)$/)[1]
  hosts.each do |type, host|
    next if host[:vm].running?
    host[:vm].network_adapters.each do |adapter|
      if adapter.attachment_type == :bridged
        adapter.host_interface = default
      end
    end
    host[:vm].save
  end
end

desc 'Starts the replica set'
task :start => :bridge do
  hosts.each do |type, host|
    host[:vm].start(run_mode)
  end
end

desc 'Get info for replica set'
task :info => :start do
  hosts.each do |type, host|
    puts "#{type.capitalize}: #{host[:vm].ip_address}"
  end
end

class VirtualBox::VM
  def find_first_interface(type)
    network_adapters.detect { |a| a.attachment_type == type }
  end

  def find_usable_interface
    host_only = find_first_interface(:host_only)
    return host_only.slot if host_only

    bridged = find_first_interface(:bridged)
    return bridged.slot if bridged

    raise "VM does not have any Host-only or bridged interfaces"
  end

  def get_ip_address
    slot = find_usable_interface
    interface.get_guest_property_value("/VirtualBox/GuestInfo/Net/#{slot}/V4/IP")
  end

  def ip_address
    sleep 1 while get_ip_address.empty?
    get_ip_address
  end
end

desc 'Prepares the VMs for chef'
task :prepare => :start do
  hosts.each do |type, host|
    sh cook, "node:#{host[:vm].ip_address}", "deploy_chef:gems=yes,ask=no"
  end
end

def write_node(host, config)
  File.open("nodes/#{host[:vm].ip_address}.json", "w") do |f|
    f.print JSON.pretty_generate(config)
  end
end

desc 'Builds the replica set'
task :cook => :start do
  write_node(hosts[:master], {
    :run_list => [ "role[mysql_master]" ],
    :mysql => {
      :server_id => 1,
      :server_repl_password => "wd0udoih289d",
      :server_root_password => "0112jhaslflh2"
    }
  })

  sh cook, "node:#{hosts[:master][:vm].ip_address}", "configure"

  # Need to connect and get log file/log pos info here
  write_node(:slave, {
    :run_list => [ "role[mysql_slave]" ],
    :mysql => {
      :server_id => 2,
      :server_root_password => "291hsashdy912i",
      :master => {
        :host => hosts[:master][:vm].ip_address,
        :user => "repl",
        :password => "wd0udoih289d",
        :log_file => "mysql-bin.000001",
        :log_pos => 37169
      }
    }
  })

  sh cook, "node:#{hosts[:slave][:vm].ip_address}", "configure"
end

desc 'Stops the replica set'
task :stop do
  hosts.each do |type, host|
    host[:vm] = VirtualBox::VM.find(host[:name])
    host[:vm].shutdown if host[:vm].running?
  end
end

desc 'Destroys the replica set VMs'
task :destroy => :stop do
  hosts.each do |type, host|
    while host[:vm].running?
      sleep 1
      host[:vm].reload
    end
    sleep 1 # One more sleep incase it's not _really_ stopped
    host[:vm].destroy(:destroy_medium => true)
  end
end

