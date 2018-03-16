#!/usr/local/bin/expect
set ip_add [lindex $argv 0]
set username [lindex $argv 1]
set password [lindex $argv 2]
set equipment_name [lindex $argv 3]
set tftp_ip "10.100.51.2"
set ftp_un "tradmin"
set ftp_pw "tradmin"
set timeout 3
		switch $equipment_name{
		"OS-9700" {spawn ssh $ip_add}
		"default" {spawn telnet $ip_add}
		}
		expect "n*:"
		send "$username\n"
		expect "*ass*"
		send "$password\n"
			 switch $equipment_name {
			 "Junos" {set pw_false_chk "*incorr*"}
			 "Summit200" {set pw_false_chk "*failed*"}
			 "XOS" {set pw_false_chk "*incorr*"}
			 "AOS" {set pw_false_chk "*failure*"}
			 "OS6602" {set pw_false_chk "*failure*"}
			 "OS9700" {set pw_false_chk "*failure*"}
			 "HP" {set pw_false_chk "*failed*"}
			 "Cisco" {set pw_false_chk "*invalid*"}
			 "default" {
				 set timeout 1;
				 set fd [open /home/handyman/Configbackup/Configbackup.log a]
				 puts $fd "[clock format [clock seconds] -format "%Y/%m/%d %H:%M:%S"] $ip_add Login equipment name mapping error"
				 close $fd
				 set pw_false_chk ""
				 exit
				 }
			}	
		expect {
			 "$pw_false_chk" {
			 set timeout 1;
			 set fd [open /home/handyman/Configbackup/Configbackup.log a];
			 puts $fd "[clock format [clock seconds] -format "%Y/%m/%d %H:%M:%S"] $ip_add Logging failure";
			 close $fd;
			 }
			 "*>*" {
				 switch $equipment_name {
					 "Junos" {send "configure\n"
					 expect "*#*"
					 send "save $ip_add.cfg\n"
					 send "exit\n"
					 expect ">"
					 send "start shell\n"
					 expect "%"
					 send "tftp $tftp_ip\n"
					 expect "*ftp*"
					 send "put $ip_add.cfg\n"
					 expect "*seconds*"
					 send "quit\n"
\					 expect "%"
					 send "exit\n"
					 expect ">"
					 send "exit\n"}
			 				 
					 "Summit200" {
					 send "upload configuration $tftp_ip $ip_add.cfg\n"
					 expect "*>*"
					 send "exit\n"}
					 
					 "XOS" {
					 send "upload configuration $tftp_ip $ip_add.cfg vr VR-Default\n"
					 expect "*>*"
					 send "exit\n"}
					 
					 "AOS" {
					 send "tftp $tftp_ip put source-file /flash/working/boot.cfg destination-file $ip_add.cfg ascii\n"
					 expect \"*->\"
					 send "exit\n"}
					 
					 "OS9700" {
					 send "tftp $tftp_ip put source-file /flash/working/boot.cfg destination-file $ip_add.cfg ascii\n"
					 expect \"*->\"
					 send "exit\n"}
					 
					 "OS6602" {
					 send "cd working\n"
					 expect \"*->\"
					 send "cp boot.cfg $ip_add.cfg\n"
					 expect \"*->\"
					 send "ftp $ip_tftp\n"
					 expect "*ame*"
					 send "$ftp_un\n"
					 expect "*assw*"
					 send "$ftp_pw\n"
					 expect "*>*"
					 send "put $ip_add.cfg\n"
					 expect "*>*"
					 send "bye\n"
					 expect "*>*"
					 send "rm $ip_add.cfg\n"
					 expect "*>*"
					 send "exit\n"
					 }
					 
					 "HP" {
					 send "backup startup-configuration to $tftp_ip $ip_add.cfg\n"
					 expect "*>*"
					 send "quit\n"}
					 
					 "default" {
					 set timeout 1;
					 set fd [open /home/handyman/Configbackup/Configbackup.log a]
					 puts $fd "[clock format [clock seconds] -format "%Y/%m/%d %H:%M:%S"] $ip_add Upload equipment name mapping error"
					 close $fd
					 exit}
					}
				}
		
			 "*#*" {
					switch $equipment_name {
					 "Cisco" {
					 send "copy running-config tftp:\n"
					 expect "*host*"
					 send "$tftp_ip\n"
					 expect "*filename*"
					 send "$ip_add.cfg\n"
					 expect "*secs*"
					 send "exit\n"}
					 
					 "default" {
					 set timeout 1;
					 set fd [open /home/handyman/Configbackup/Configbackup.log a]
					 puts $fd "[clock format [clock seconds] -format "%Y/%m/%d %H:%M:%S"] $ip_add Upload equipment name mapping error"
					 close $fd
					 exit}					 
					 }
				}
			}

expect eof