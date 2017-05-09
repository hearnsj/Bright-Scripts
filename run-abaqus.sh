#!/bin/bash
#SBATCH --partition=stdcomp
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=20


#SBATCH --job-name=damage
#SBATCH --output=damage.out

#SBATCH --mail-type  BEGIN,END
#SBATCH --mail-user harnsj@gmailc.om

module load abaqus

# Just do this once:
# use mpi-selector to select the MPI you wish to use
#   mpi-selector --set --user openmpi_gcc_hfi-1.10.2
module load hwloc
module load python-hostlist


# license is running on 193.60.67.246  port 27000 
# this is set within the abaqus modulefile
# export ABAQUSLM_LICENSE_FILE=27000@193.60.67.246

#/cm/shared/apps/abaqus/License/lmutil lmstat -a 
#which abaqus



unset SLURM_GTIDS
mkdir $SCRATCH/abqscratch  > /dev/null 2>&1
export scratch=$SCRATCH/abqscratch
export TMPDIR=$SCRATCH/abqscratch

# create a local Abaqus env file - this will be looked at after the one on /cm/shared/abaqus
envFile=abaqus_v6.env
if [[ -f $envFile ]]; then
    rm $envFile
fi
echo 'import os'>>$envFile
echo 'run_mode=BATCH'>>$envFile

#echo "mp_file_system=(DETECT,DETECT)" >> $envFile
# we are using the global BeeGFS filesystem 
echo 'mp_file_system=(SHARED,SHARED)' >> $envFile

# echo "user=damagefailcomplate_cps4r.f" >> $envFile
# set the compiler flags relevant to gfortran
echo 'fortCmd = "gfortran"' >> $envFile
echo "compile_fortran = [fortCmd + ' -c -fPIC -I%I ']" >> $envFile

echo 'mp_mode=MPI' >> $envFile
echo 'mp_mpi_implementation=IMPI' >> $envFile  
# echo "impipath = driverUtils.locateFile(os.environ.get('ABA_PATH', ''), 'impi-4.1.1/bin', 'mpiexec.hydra')">>$envFile
# echo "impipath = /cm/shared/apps/intel/mpi/5.1.2.150/intel64/bin/mpiexec.hydra
# echo "mpiCppImpl = '-DABQ_MPI_IMPI'">>$envFile

echo "mp_mpirun_path = {IMPI:'/cm/shared/apps/intel/mpi/5.1.2.150/intel64/bin/mpiexec.hydra', \\"  >> $envFile
echo "OMPI:'/usr/mpi/gcc/openmpi-1.10.2-hfi/bin/mpirun'}   "  >> $envFile
#                 MVAPICH:'/usr/mpi/gcc/mvapich2-2.1-hfi/bin/mpirun',\
#                 PCMPI:'/opt/platform_mpi/bin/mpirun'}


# use python-hostlist to expand the SLURM_NODELIST and create the correctly formatted string for mp_host_list. 
#
#mp_host_list
#List of host machine names to be used for an MPI-based parallel Abaqus analysis, including the number of processors to be used on each machine; for example,
#mp_host_list=[['maple',1],['pine',1],['oak',2]]
#indicates that, if the number of cpus specified for the analysis is 4, the analysis will use one processor on a machine called maple,
# one processor on a machine called pine, and two processors on a machine called oak. 
#The total number of processors defined in the host list has to be greater than or equal to the number of cpus specified for the analysis. 
#If the host list is not defined, Abaqus will run on the local system. 
#When using a supported queuing system, this parameter does not need to be defined. If it is defined, it will get overridden by the queuing environment.
#
mp_host_list=$(hostlist  --append-slurm-tasks=$SLURM_TASKS_PER_NODE  -d -e -p [\' -a \',  -s ], $SLURM_NODELIST)

# put the keyword string on mp_host_list and add [ ] brackets . Need a second trailing bracket at the end
mp_host_list="mp_host_list=["${mp_host_list}"]]"
#echo $mp_host_list

echo ${mp_host_list} >> $envFile


echo 'max_history_requests=0' >> $envFile







abaqus job=damagefailcomplate_cps4r input=damagefailcomplate_cps4r.inp \
 double cpus=$SLURM_NTASKS interactive standard_parallel=all \
 user=damagefailcomplate_cps4r.f \
 -verbose 1

exit
