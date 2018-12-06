#
# Cookbook Name:: mesos_cluster
# Recipe:: install_mesos
#
#

# This cookbook only installs mesos and marathon software on the Mesos Master nodes (works for ubuntu linux)

case node["platform"]
when "ubuntu"
   # Install Ubuntu version of Mesos
   if node[:mesos_node] == "yes" && node[:mesos_installed] == "no"
	# Add apt keys for Mesos repo
	bash "add_mesos_gpg_key" do
  	user "root"
  	cwd "/"
  	code <<-EOT
		sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E56151BF
		DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
		CODENAME=$(lsb_release -cs)
		# Add the repository
		echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" | \
  		sudo tee /etc/apt/sources.list.d/mesosphere.list
		sudo apt-get -y update
  	EOT
	end
	# Install mesos, marathon and zookeeper(zookeeper is added as a dependency)
        ruby_block "adding mesos hostname to /etc/hosts" do
                block do
                        fe1 = Chef::Util::FileEdit.new("/etc/hosts")
                        fe1.insert_line_if_no_match(/^#{node['ipaddress']} #{node['hostname']}/,
                               "#{node['ipaddress']} #{node['hostname']}")
                        fe1.write_file
                end
        end

	package "mesos" do 
		options "-q -y"
		action :install
	end	
	
	package "zookeeper" do 
		options "-q -y"
		action :install
	end	

	package "marathon" do 
		options "-q -y"
		action :install
	end	

	# Set node attribute to yes after successful mesos software install
	node.set[:mesos_installed] = "yes"
    end
when "redhat", "centos"
	# Try and install Mesos on Centos or RHEL
	Chef::Log.info("Oops!!...Detected Enterprise Linux...stop wasting time...install Ubuntu or CoreOS")
end
