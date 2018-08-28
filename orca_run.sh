#!/bin/bash

# Script to run Orca quantum chemistry program, moving the temporary files to a scratch directory /scr/$USER

# Nprocs is the number of processors to be used
# Maxcore is the ORCA maximum memory per core.
# Use -mail to send an email to you in the end of the calculation if this option is configured in your system
# -a is to copy any additional files to the run directory, as example, .gbw files to read molecular orbitals.

# PATH to orca, SET THIS
ORCAPATH="/programs/orca-4.0.1/orca"

# Calculation directory
CALCDIR="${PWD}"
# Variables
DATE=`date "+%d-%m-%Y"`
TIME=`date "+%H:%M:%S"`
input=""
output=""
nprocs=""
email=""
afile=""
maxcore=""
usage="SCRIPT USAGE:

orca_run -i input.inp -o output.out -p nprocs -m maxcore -a moread.gbw -e email@addres.com hostsender

Only input is obligatory, default output = input-basename.out"

# Input options, passing arguments
while getopts i:o:p:a:e:m:h option
do
	case "${option}" in
		i)	input=${OPTARG}
			# New input to be placed in the runfiles folder to see modifications
			inputNEW="${input%.*}.new.inp"
			RUNDIR="/scr/${USER}/orca/${input%.*}-$$"
			;;
		o)	output=${OPTARG};;
		p)	nprocs=${OPTARG};;
		a)	afile=${OPTARG};;
		e)	email=${OPTARG}
			eval "hostsender=\${$OPTIND}"
			shift 2
			;;
		m)	maxcore=${OPTARG};;
		h | *) # Display help.
			echo "$usage"
			exit 0
		;;
	esac
done

### START and show what will be done ###
echo "Orca will run on node $HOSTNAME in $DATE at $TIME with the following options" > ${input%.*}.nodes
echo "input = $input" >> ${input%.*}.nodes
echo "output = $output" >> ${input%.*}.nodes
echo "number of processors = $nprocs" >> ${input%.*}.nodes
echo "maxcore memory = $maxcore" >> ${input%.*}.nodes
echo "extrafile = $afile" >> ${input%.*}.nodes
echo "mail = $email send by host $hostsender" >> ${input%.*}.nodes
echo "scrDIR = $RUNDIR" >> ${input%.*}.nodes


#### Starting job script ####
mkdir -p "${RUNDIR}"
cd "${RUNDIR}"
cp "${CALCDIR}/$input" "${RUNDIR}" # Copy input to run dir

### Argument Cases ###
# Alert if email will be sent
if [ -n "$email" ]; then
	echo "An email will be send to $email via host $hostsender when job is finished."
fi
# Case there is extra files to copy
if [ -n "$afile" ]; then
	cp "${CALCDIR}/$afile" "${RUNDIR}"
fi
# Case no output is specified, output will be same input name with .out extension
if [ -z "$output" ]; then
	output=${input%.*}.out
fi
# Case nprocs was specified
if [ -n "$nprocs" ]; then
	## Erase possible %pal configuration in input
	sed -i -e "/^%pal.*$/Id" $input
	## Write the number of processors to inp file with requested %pal configuration
	echo "%Pal nprocs $nprocs end" | cat - $input > inputOR.temp && mv inputOR.temp $input
fi
if [ -n "$maxcore" ]; then
# Case maxcore was specified
	## Erase possible %maxcore configuration in input
	sed -i -e "/^%maxcore.*$/Id" $input
	## Write the number of processors to inp file with requested %maxcore configuration
	echo "%maxcore $maxcore" | cat - $input > inputOR.temp && mv inputOR.temp $input
fi

#### Run the program itself and alert the user ####
echo "Orca will run with command:
 nohup ${ORCAPATH} ${RUNDIR}/${input} > "${CALCDIR}"/$output
 Run directory = ${RUNDIR}"
nohup ${ORCAPATH} $input > "${CALCDIR}"/$output
# Move old input file to a .new.inp file so user knows what changed
mv $input $inputNEW
## Finally, move the files from the calculation to their folder
mkdir -p "${CALCDIR}/${input%.*}-runfiles"
mv ${input%.*}* "${CALCDIR}/${input%.*}-runfiles"

# If email was requested send it
if [ -n "$email" ]; then
	echo "echo	"ssh $USER@$hostsender "echo "The job $input has ended on $(hostname)." | mail -s "JOB_DONE!" $email" 
fi
