#!/bin/bash

# alert email address
alertemail=hpcadmins@greenwich.ac.uk

# this is the sensor value we trigge
metric=BB_Inlet_Temp

warnvalue=35        #send some email
shutdownvalue=40     # shutdown the server
poweroffvalue=50     # power off immediately

# to show actions
# monitoring actions list



for server in $(cmsh -c "device; foreach -c compute (get hostname)")
do
 echo Setting temperature thresholds for $server

 cmsh -c "monitoring; setup; use $server ; metricconf ;  use $metric; thresholds; \
         use HighTemperatureWarn; \
         set severity 20 ; set upperbound yes; set bound $warnvalue; \
         set actions SendEmail $alertemail;  commit"

 cmsh -c "monitoring; setup; use $server ; metricconf ;  use $metric; thresholds; \
         use HighTemperatureShutdown; \
         set severity 20 ; set upperbound yes; set bound $shutdownvalue; \
         set actions Shutdown;  commit"

 cmsh -c "monitoring; setup; use $server ; metricconf ;  use $metric; thresholds; \
         use HighTemperaturePoweroff; \
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
         use HighTemperatureWarn; \
         set severity 20 ; set upperbound yes; set bound $warnvalue; \
         set actions SendEmail $alertemail;  commit"

 cmsh -c "monitoring; setup; use $server ; metricconf ;  use $metric; thresholds; \
         use HighTemperatureShutdown; \
         set severity 20 ; set upperbound yes; set bound $shutdownvalue; \
         set actions Shutdown;  commit"

 cmsh -c "monitoring; setup; use $server ; metricconf ;  use $metric; thresholds; \
         use HighTemperaturePoweroff; \
         set severity 20 ; set upperbound yes; set bound $poweroffvalue; \
         set actions Power\ Off;  commit"

done

exit


