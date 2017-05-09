#!/bin/bash

cmsh -c "monitoring ; setup ; healthconf compute ; list ";

for hcheck in $(cmsh -c "monitoring; setup; healthconf compute;  foreach * (get healtcheck)")
do
 echo $hcheck
done  

exit


cmsh
monitoring
setup
healthconf
use smart


set failactions  SendEmail gold@xma.co.uk,john.hearns@xma.co.uk
set passactions  SendEmail gold@xma.co.uk,john.hearns@xma.co.uk

commit
#!/bin/bash

for c in {05..13} 
do
   echo $c
   cmsh -c "device add chassis chassis${c}; commit;"
   cmsh -c "device use chassis${c} ; set rack rack2; commit;"
   cmsh -c "device use chassis${c} ; set deviceheight 2; commit;"
   cmsh -c "device use chassis${c} ; set layout 2,2; commit;"
   cmsh -c "device use chassis${c} ; set containerindex 5; commit;"
done

 foreach -v  * (set failactions SendEmail gold@xma.co.uk,john.hearns@xma.co.uk; commit)  ;
