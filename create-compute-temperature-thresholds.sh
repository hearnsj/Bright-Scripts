#!/bin/bash

# alert email address
alertemail=hearnsj@gmail.com

# this is the sensor value which is used to trigegr on
# We need to examine the IPMI sensors output and choose and air temperature sensor
# ipmitool sensor will show all the sensore values
# Unfortunately - manufacturers have different names for their sensors
metric=BB_Inlet_Temp   # this is relevant to Intel servers
# metric=System_Temp   # this is relevant to Supermicro servers. NOTE the space character
#Ambient_Temp          # shoul dbe good for Dell servers


warnvalue=35        #send some email
shutdownvalue=40     # shutdown the server
poweroffvalue=50     # power off immediately

# to show actions
# monitoring actions list



for server in $(cmsh -c "device; foreach -c compute (get hostname)")
do
 echo Setting temperature thresholds for $server

 cmsh -c "monitoring; setup; use $server ; metricconf ;  use $metric; thresholds; \
         add HighTemperatureWarn; \
         set severity 20 ; set upperbound yes; set bound $warnvalue; \
         set actions SendEmail $alertemail;  commit"

 cmsh -c "monitoring; setup; use $server ; metricconf ;  use $metric; thresholds; \
         add HighTemperatureShutdown; \
         set severity 20 ; set upperbound yes; set bound $shutdownvalue; \
         set actions Shutdown;  commit"

 cmsh -c "monitoring; setup; use $server ; metricconf ;  use $metric; thresholds; \
         add HighTemperaturePoweroff; \
         set severity 20 ; set upperbound yes; set bound $poweroffvalue; \
         set actions Power\ Off;  commit"


# cmsh -c "monitoring; setup; use $server ; metricconf ; list ; use $metric; thresholds; \
#         show HighTemperatureShutdown"


done

# the GPU servers now
$metric=System_Temp

for server in $(cmsh -c "device; foreach -c gpu (get hostname)")
do
 echo Setting temperature thresholds for $server

 cmsh -c "monitoring; setup; use $server ; metricconf ;  use $metric; thresholds; \
         add HighTemperatureWarn; \
         set severity 20 ; set upperbound yes; set bound $warnvalue; \
         set actions SendEmail $alertemail;  commit"

 cmsh -c "monitoring; setup; use $server ; metricconf ;  use $metric; thresholds; \
         add HighTemperatureShutdown; \
         set severity 20 ; set upperbound yes; set bound $shutdownvalue; \
         set actions Shutdown;  commit"

 cmsh -c "monitoring; setup; use $server ; metricconf ;  use $metric; thresholds; \
         add HighTemperaturePoweroff; \
         set severity 20 ; set upperbound yes; set bound $poweroffvalue; \
         set actions Power\ Off;  commit"

done

exit


