## INSTALLATION AND START-UP

#### Requirements
* Ubuntu OS 18.04
* GNU-Radio 3.7.13.4 (check your version by typing gnuradio-companion --version)
* UHD 3.14.0 (check your version by typing uhd_usrp_probe --version)
* gr-ettus
* Xilinx Vivado Vivado HLS 2017.4
* Python 2

### Installing UHD and GNU Radio on Linux

> *NOTE: para ver el tutorial en la web oficial de Ettus sobre cómo instalar UHD and GNU Radio on Linux, [**haz clic en este enlace.**](https://kb.ettus.com/Building_and_Installing_the_USRP_Open-Source_Toolchain_(UHD_and_GNU_Radio)_on_Linux)*

1. ##### Install Python 2:
~~~
sudo apt install python
sudo apt install python-pip
~~~

2. ##### Install and update dependencies:
**On ubuntu systems, type:**
~ sudo apt-get update

**On ubuntu 18.04, type:**
~~~
sudo apt-get -y install git swig cmake doxygen build-essential libboost-all-dev libtool libusb-1.0-0 libusb-1.0-0-dev libudev-dev libncurses5-dev libfftw3-bin libfftw3-dev libfftw3-doc libcppunit-1.14-0 libcppunit-dev libcppunit-doc ncurses-bin cpufrequtils python-numpy python-numpy-doc python-numpy-dbg python-scipy python-docutils qt4-bin-dbg qt4-default qt4-doc libqt4-dev libqt4-dev-bin python-qt4 python-qt4-dbg python-qt4-dev python-qt4-doc python-qt4-doc libqwt6abi1 libfftw3-bin libfftw3-dev libfftw3-doc ncurses-bin libncurses5 libncurses5-dev libncurses5-dbg libfontconfig1-dev libxrender-dev libpulse-dev swig g++ automake autoconf libtool python-dev libfftw3-dev libcppunit-dev libboost-all-dev libusb-dev libusb-1.0-0-dev fort77 libsdl1.2-dev python-wxgtk3.0 git libqt4-dev python-numpy ccache python-opengl libgsl-dev python-cheetah python-mako python-lxml doxygen qt4-default qt4-dev-tools libusb-1.0-0-dev libqwtplot3d-qt5-dev pyqt4-dev-tools python-qwt5-qt4 cmake git wget libxi-dev gtk2-engines-pixbuf r-base-dev python-tk liborc-0.4-0 liborc-0.4-dev libasound2-dev python-gtk2 libzmq3-dev libzmq5 python-requests python-sphinx libcomedi-dev python-zmq libqwt-dev libqwt6abi1 python-six libgps-dev libgps23 gpsd gpsd-clients python-gps python-setuptools
~~~

3. ##### Building and installing UHD from source code:
* Create the rfnoc folder.
~~~
cd 
mkdir rfnoc
cd rfnoc
~~~

* Clone the repository.
~~~
#git clone https://github.com/EttusResearch/uhd
git clone --recursive https://github.com/EttusResearch/uhd
cd uhd
git checkout v3.14.0.0
git submodule init
git submodule update
cd host
mkdir build
cd build

cmake -DENABLE_RFNOC=ON ../
make -j 7
sudo make install
sudo ldconfig

#include in .bashrc file
export LD_LIBRARY_PATH=/usr/local/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
~~~