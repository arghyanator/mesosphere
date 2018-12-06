#
# Cookbook Name:: mesos_cluster
# Recipe:: create_mesos_slave
#
#

# This cookbook only creates a mesos slave node (up to 3 max nodes in the cookbook)

case node["platform"]
when "ubuntu"
	# Create Mesos Slave node
    if node[:mesos_node] == "yes" && node[:mesos_installed] == "yes" && node[:mesos_slave] == "no"
	Chef::Log.info("Configuring Mesos slave node...")
	# Get master information from Data Bag
	node_info = Chef::DataBagItem.load("mesos", "mesos_cluster")
        mesos_master_nodeid1 = node_info["master_nodeid1"]
        mesos_master_nodeid2 = node_info["master_nodeid2"]
        mesos_master_nodeid3 = node_info["master_nodeid3"]
        mesos_master_nodeid1_ip = node_info["master_nodeid1_ip"]
        mesos_master_nodeid2_ip = node_info["master_nodeid2_ip"]
        mesos_master_nodeid3_ip = node_info["master_nodeid3_ip"]

	# Disable Zookeeper, Mesos-master and Marathon autostart
        file "/etc/init/mesos-master.override" do
                action :delete
                ignore_failure true
        end
        cookbook_file "/etc/init/mesos-master.override" do
                source "mesos-slave.override"
                mode 0644
                owner "root"
                group "root"
        end
	
        file "/etc/init/zookeeper.override" do
                action :delete
                ignore_failure true
        end     
        cookbook_file "/etc/init/zookeeper.override" do
                source "zookeeper.override"
                mode 0644
                owner "root"
                group "root"
        end

        file "/etc/init/marathon.override" do
                action :delete
                ignore_failure true
        end     
        cookbook_file "/etc/init/marathon.override" do
                source "marathon.override"
                mode 0644
                owner "root"
                group "root"
        end


	# Set zookeeper IP configurations on each node for mesos 
	template '/etc/mesos/zk' do
               	source 'mesos_zk.erb'
               	mode 0644
               	owner 'root'
               	group 'root'
               	variables(
       			:mesos_master_nodeid1_ip => "#{mesos_master_nodeid1_ip}",
       			:mesos_master_nodeid2_ip => "#{mesos_master_nodeid2_ip}",
       			:mesos_master_nodeid3_ip => "#{mesos_master_nodeid3_ip}"
               	)
        end

	# Enable Docker support
	# Install Docker packages from docker.io
        bash "add_docker_gpg_key" do
        user "root"
        cwd "/"
        code <<-EODOCK
                sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 36A1D7869245C8950F966E92D8576A8BA88D21E9
                DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
                CODENAME=$(lsb_release -cs)
                # Add the repository
                echo "deb https://get.docker.com/ubuntu docker main" | \
                sudo tee /etc/apt/sources.list.d/docker.list
                sudo apt-get -y update
		sudo apt-get -y install apt-transport-https
		sudo apt-get -y install lxc-docker
        EODOCK
        end

	# Change Mesos Slave configs for Docker
	file "/etc/mesos-slave/containerizers" do
                action :delete
                ignore_failure true
        end
        cookbook_file "/etc/mesos-slave/containerizers" do
                source "containerizers"
                mode 0644
                owner "root"
                group "root"
        end

        file "/etc/mesos-slave/executor_registration_timeout" do
                action :delete
                ignore_failure true
        end
        cookbook_file "/etc/mesos-slave/executor_registration_timeout" do
                source "executor_registration_timeout"
                mode 0644
                owner "root"
                group "root"
        end

	# Re-Start the Mesos Slave daemons
        service "mesos-slave" do
		provider Chef::Provider::Service::Upstart
                action :restart
        end
	
	# Set Node Attribute to indicate Mesos-master installed and clustered
	node.set[:mesos_slave] = "yes"
   else 
	Chef::Log.info("Mesos slave configurations skipped...either due to Node Attributes...or slave not required")
   end
	
when "redhat", "centos"
	# Lets see...
   if node[:mesos_node] == "yes" && node[:mesos_installed] == "yes" && node[:mesos_slave] == "no"
	Chef::Log.info("nope...can't do it...its an Enterprise Linux platform....")
   else
	Chef::Log.info("Mesos slave configuration skipped...either due to Node Attributes...or slave not required")
   end
end

