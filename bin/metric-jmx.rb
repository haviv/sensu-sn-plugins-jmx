#!/usr/bin/env ruby
# Jmx Wrapper
# ===
#
# This is a wrapper around java jmx program
#
# DEPENDENCIES:
#   gem: sensu-plugin
#  
#
# USAGE:
#
#   metric-jmx.rb -c "/opt/java/*" -v "-Djmx.remote.protocol.provider.pkgs=weblogic.management.remote" -a "-s service:jmx:rmi:///jndi/rmi://localhost:9000/jmxrmi  -h localhost -f /tmp/jmx.json"
#
# 

require 'sensu-plugin/metric/cli'


# Class that collects and outputs SNMP metrics in graphite format
class JmxWrapper < Sensu::Plugin::Metric::CLI::Graphite
  option :java,
         short: '-j java_executable',
         description: 'java executable path, for example /usr/bin/java',
         default: 'java'

  option :classapth,
         short: '-c classpath',
         description: 'classpath to add',
         default: ''

  option :vm_arguments,
         short: '-v vm arguments',
         description: 'vm arguments',
         default: ''


  option :jmx_arguments,
         short: '-a arguments',
         description: 'arguments  -s service_url -f config_file -ff config_json -h prefix [-u username] [-p password] [-v]'

  def run
    jmx_jar = Gem.bin_path("sensu-sn-plugins-jmx", "metric-jmx.rb", ">= 0.a")
    jmx_jar.sub! "metric-jmx.rb", "jmx.jar"
    delim = ":"
    if Gem.win_platform?
      delim = ";"
    end
    cp = config[:classapth].tr(":", delim)
    cp = cp.tr(";", delim)

    cmd = config[:java] + " " + config[:vm_arguments] + " -cp \"" + cp + delim + jmx_jar + "\" com.snc.sw.mon.jmx.GenericJMX "+config[:jmx_arguments]
    
    IO.popen(cmd) do |io|
      output io.read
    end
    exit  $?.exitstatus
  end

end