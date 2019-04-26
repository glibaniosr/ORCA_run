# ORCA_run

ORCA_run is a shell/bash script to help users run electronic structure calculations with ORCA software developed and maintained by prof. Frank Neese and coworkers at Max Planck Institute for Chemical Energy Conversion.

It's official website can be acessed at: **https://orcaforum.kofo.mpg.de**

## About ORCA software for eletronic structures calculations

**The following text was taken from ORCA official website above.**

"The program ORCA is a modern electronic structure program package written by F. Neese, with contributions from many current and former coworkers and several collaborating groups. The binaries of ORCA are available free of charge for academic users for a variety of platforms.
ORCA is a flexible, efficient and easy-to-use general purpose tool for quantum chemistry with specific emphasis on spectroscopic properties of open-shell molecules. It features a wide variety of standard quantum chemical methods ranging from semiempirical methods to DFT to single- and multireference correlated ab initio methods. It can also treat environmental and relativistic effects.
Due to the user-friendly style, ORCA is considered to be a helpful tool not only for computational chemists, but also for chemists, physicists and biologists that are interested in developing the full information content of their experimental data with help of calculations."

**More help using ORCA can be found at ORCA Input Library: https://sites.google.com/site/orcainputlibrary/**

## Usage

To use ORCA_run, first you need to set the path to ORCA in the orca_dir enviroment variable. As example, you can export it in your .bash_profile:

> export orca_dir="/path/to/orca"

Then, the command to run an ORCA job called from ORCA_run follows the syntax:

> orca_run -i input.inp -o output.out -p nprocs -m maxcore -a file1.gbw -e email@address.com hostsender

**nprocs** is the number of processors to be used

**maxcore** is the ORCA maximum memory per core in MB.

Use -e to send an email to you in the end of the calculation if this option is configured in your system.

Only input is obligatory, default output = input-basename.out.

-a is to copy any additional files to the run directory. i.e. .gbw files to read molecular orbitals or .xyz files for multiple xyz structures runs. If you need **MORE** than one -a file, the multiple files **MUST** be specified between double quotes and separated by spaces. 

> -a "file1.gbw file2.xyz"
