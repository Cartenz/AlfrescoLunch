class alfresco::install::alfresco-ce inherits alfresco::install {

  case ($alfresco_version){
      '4.2.f', '4.2.x': {

    

        exec { "retrieve-alfresco-ce":
          user => 'tomcat7',
          command => "wget -q ${urls::alfresco_ce_url} -O ${download_path}/${urls::alfresco_ce_filename}	",
          path => "/usr/bin",
          creates => "${download_path}/${urls::alfresco_ce_filename}",
          timeout => 0,
          require => File[$download_path],
        }

        file { "${download_path}/alfresco":
          ensure => directory,
          owner => 'tomcat7',
        }

        exec { "unpack-alfresco-ce":
          user => 'tomcat7',
          command => "unzip -o ${download_path}/${urls::alfresco_ce_filename} -d ${download_path}/alfresco",
          path => "/usr/bin",
          require => [ 
            Exec["retrieve-alfresco-ce"],
            Exec["copy tomcat to ${tomcat_home}"], 
            Package["unzip"], 
            File["${download_path}/alfresco"],
          ],
          creates => "${download_path}/alfresco/README.txt",
        }


	      # the war files
	      exec { "${tomcat_home}/webapps/alfresco.war":
          user => 'tomcat7',
		      command => "cp ${alfresco_war_loc}/alfresco.war ${tomcat_home}/webapps/alfresco.war",
		      require => Exec["unpack-alfresco-ce"],
          creates => "${tomcat_home}/webapps/alfresco.war",
          path => '/bin:/usr/bin',
          notify => Service['alfresco-start']
	      }
	      exec { "${tomcat_home}/webapps/share.war":
          user => 'tomcat7',
		      command => "cp ${alfresco_war_loc}/share.war ${tomcat_home}/webapps/share.war",
          creates => "${tomcat_home}/webapps/share.war",
          path => '/bin:/usr/bin',
          notify => Service['alfresco-start'],
          require => [
            File["${alfresco_base_dir}/amps"],
		        Exec["unpack-alfresco-ce"],
          ]
	      }


        exec { 'retrieve-spp':
          user => 'tomcat7',
          command => "/usr/bin/wget ${urls::spp_v4}",
          cwd => $download_path,
          require => File[$download_path],
          creates => "${download_path}/${urls::spp_v4_zipname}",
        }

        exec { 'unpack-spp':
          user => 'tomcat7',
          command => "/usr/bin/unzip ${download_path}/${urls::spp_v4_zipname}",
          cwd => "${alfresco_base_dir}/amps",
          creates => "${alfresco_base_dir}/amps/${urls::spp_v4_name}",
          require => [ File[$download_path], Exec['retrieve-spp'], ], 
        }


      }
      '5.0.c', '5.0.x': {
	      exec { "${tomcat_home}/webapps/alfresco.war":
          user => 'tomcat7',
          command => "wget ${urls::alfresco_war_50x} -O alfresco.war",
          cwd => "${tomcat_home}/webapps/",
          path => "/usr/bin",
          creates => "${tomcat_home}/webapps/alfresco.war",
          require => File["${tomcat_home}/webapps/"],
          timeout => 0,
        }

	      exec { "${tomcat_home}/webapps/share.war":
          user => 'tomcat7',
          command => "wget ${urls::share_war_50x} -O share.war",
          cwd => "${tomcat_home}/webapps/",
          path => "/usr/bin",
          creates => "${tomcat_home}/webapps/share.war",
          require => File["${tomcat_home}/webapps/"],
          timeout => 0,
        }

        file { "${tomcat_home}/webapps":
          ensure => directory,
          require => File["${tomcat_home}"],
          owner => 'tomcat7',
        }
        
        exec { 'retrieve-spp-amp':
          user => 'tomcat7',
          command => "wget ${urls::spp_amp_v5}",
          path => '/usr/bin',
          cwd => "${alfresco_base_dir}/amps",
          creates => "${alfresco_base_dir}/amps/${urls::spp_amp_v5_name}",
        }

      }
      'NIGHTLY': {
        exec { "retrieve-nightly":
          user => 'tomcat7',
		      timeout => 0,
          command => "wget ${urls::nightly}",
          cwd => $download_path,
          require => [
            File[$download_path],
          ],
          path => '/usr/bin',
          creates => "${download_path}/${urls::nightly_name}",
        }

        exec { 'unpack-nightly':
          user => 'tomcat7',
          require => [ Exec['retrieve-nightly'], ],
          command => "unzip ${download_path}/${urls::nightly_name} -d ${alfresco_base_dir}",
          path => '/usr/bin',
          creates => "${alfresco_base_dir}/README.txt",
        }

        exec { 'rename-web-server-folder':
          user => 'tomcat7',
          require =>  Exec['unpack-nightly'], 
          # "mv -n" to ensure that this isn't getting applied out of order
          command => "mv -n ${alfresco_base_dir}/web-server ${alfresco_base_dir}/tomcat",
          path => '/bin',
          before => Exec['unpack-tomcat7'],
          creates => "${alfresco_base_dir}/tomcat/webapps",
        }

        exec { "${tomcat_home}/webapps/alfresco.war":
          user => 'tomcat7',
          command => "/usr/bin/touch /tmp/fake.get.alfresco.war",
          creates => "/tmp/fake.get.alfresco.war",
        }

        exec { "${tomcat_home}/webapps/share.war":
          user => 'tomcat7',
          command => "/usr/bin/touch /tmp/fake.get.share.war",
          creates => "/tmp/fake.get.share.war",
        }


      }
  }




	exec { "unpack-alfresco-war": 
    user => 'tomcat7',
		require => [
			Exec["${tomcat_home}/webapps/alfresco.war"],
      Exec['apply-addons'],
		],
    before => Service['alfresco-start'],
		path => "/bin:/usr/bin",
		command => "unzip -o -d ${tomcat_home}/webapps/alfresco ${tomcat_home}/webapps/alfresco.war && chown -R tomcat7 ${tomcat_home}/webapps/alfresco", 
		creates => "${tomcat_home}/webapps/alfresco/",
	}

	exec { "unpack-share-war": 
    user => 'tomcat7',
		require => [
			Exec["${tomcat_home}/webapps/share.war"],
      Exec['apply-addons'],
		],
    before => Service['alfresco-start'],
		path => "/bin:/usr/bin",
		command => "unzip -o -d ${tomcat_home}/webapps/share ${tomcat_home}/webapps/share.war && chown -R tomcat7 ${tomcat_home}/webapps/share", 
		creates => "${tomcat_home}/webapps/share/",
	}

}
