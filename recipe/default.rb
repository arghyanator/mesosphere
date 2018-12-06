#
# Cookbook Name:: mesos_cluster
# Recipe:: default
#
#
#

include_recipe "mesos_cluster::install_mesos"
include_recipe "mesos_cluster::cluster_mesos_master"
include_recipe "mesos_cluster::create_mesos_slave"
