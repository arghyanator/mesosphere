#
# Cookbook Name:: mesos_cluster
# Recipe:: cluster_mesos_master
#
#

# This cookbook only Mesos Master Cluster of 3 nodes max (mesos and marathon software is already installed via different recipe)

case node["platform"]
when "ubuntu"
	# Create Mesos Cluster
    if node[:mesos_node] == "yes" && node[:mesos_installed] == "yes" && node[:mesos_master] == "no"
	Chef::Log.info("Configuring Mesos Master clustering...")
	# Get Cluster information from Data Bag
	node_info = Chef::DataBagItem.load("mesos", "mesos_cluster")
	mesos_master_nodeid1 = node_info["master_nodeid1"]
	mesos_master_nodeid2 = node_info["master_nodeid2"]
	mesos_master_nodeid3 = node_info["master_nodeid3"]
	mesos_master_nodeid1_ip = node_info["master_nodeid1_ip"]
	mesos_master_nodeid2_ip = node_info["master_nodeid2_ip"]
	mesos_master_nodeid3_ip = node_info["master_nodeid3_ip"]

	# Get my node's ID and configure accordingly
	if node[:fqdn] == "#{mesos_master_nodeid1}"
		# Set Zookeeper ID
		bash "set zookeeper nodeID" do
        	user "root"
        	code <<-EOT1
                	echo "1" >/etc/zookeeper/conf/myid
        	EOT1
		end
	end
	if node[:fqdn] == "#{mesos_master_nodeid2}"
                # Set Zookeeper ID
                bash "set zookeeper nodeID" do
                user "root"
                code <<-EOT2
                        echo "2" >/etc/zookeeper/conf/myid
                EOT2
                end
	end
	if node[:fqdn] == "#{mesos_master_nodeid3}"
                # Set Zookeeper ID
                bash "set zookeeper nodeID" do
                user "root"
                code <<-EOT3
                        echo "3" >/etc/zookeeper/conf/myid
                EOT3
                end
	end

	# Set zookeeper hostname, IP configurations
	template '/tmp/zoo.cfg' do
               	source 'zoo.erb'
               	mode 0644
               	owner 'root'
               	group 'root'
               	variables(
       			:mesos_master_nodeid1_ip => "#{mesos_master_nodeid1_ip}",
       			:mesos_master_nodeid2_ip => "#{mesos_master_nodeid2_ip}",
       			:mesos_master_nodeid3_ip => "#{mesos_master_nodeid3_ip}"
               	)
        end

                bash "append zookeeper node ips..." do
                user "root"
                code <<-EOZOOC
			cat /tmp/zoo.cfg >> /etc/zookeeper/conf/zoo.cfg
			rm -f /tmp/zoo.cfg
                EOZOOC
                end
	# Restart zookeeper daemon
        service "zookeeper" do
                action :restart
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

	# Set the quorum value for mesos
	file "/etc/mesos-master/quorum" do
                action :delete
                ignore_failure true
        end
        cookbook_file "/etc/mesos-master/quorum" do
                source "quorum"
                mode 0644
                owner "root"
                group "root"
        end

	# Disable Mesos Slave daemon auto-start (on Mesos master nodes)
	file "/etc/init/mesos-slave.override" do
                action :delete
                ignore_failure true
        end
        cookbook_file "/etc/init/mesos-slave.override" do
                source "mesos-slave.override"
                mode 0644
                owner "root"
                group "root"
        end
	
	# Re-Start the Mesos and Marathon daemons
        service "mesos-master" do
		provider Chef::Provider::Service::Upstart
                action :restart
        end
	
        service "marathon" do
		provider Chef::Provider::Service::Upstart
                action :restart
        end
	
	# Set Node Attribute to indicate Mesos-master installed and clustered
	node.set[:mesos_master] = "yes"
   else 
	Chef::Log.info("Mesos Master clustering skipped...either due to Node Attributes...or Clustering not required")
   end
	
when "redhat", "centos"
	# Lets see...
   if node[:mesos_node] == "yes" && node[:mesos_installed] == "yes" && node[:mesos_master] == "no"
	Chef::Log.info("nope...can't do it...its an Enterprise Linux platform....")
   else
	Chef::Log.info("Mesos Master clustering skipped...either due to Node Attributes...or Clustering not required")
   end
end

