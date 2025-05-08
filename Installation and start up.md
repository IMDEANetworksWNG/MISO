# INSTALLATION AND START-UP

## Useful information
> Below is a list of links to the official Ettus website that serve as a reference in case you have any doubts when installing the libraries explained below.

* [1] [Getting Started with RFNoC Development](https://kb.ettus.com/Getting_Started_with_RFNoC_Development)
* [2] [Building and Installing the USRP Open-Source Toolchain (UHD and GNU Radio) on Linux](https://kb.ettus.com/Building_and_Installing_the_USRP_Open-Source_Toolchain_(UHD_and_GNU_Radio)_on_Linux)
* [3] [RFNoC (UHD 3.0)](https://kb.ettus.com/RFNoC_(UHD_3.0)#Xilinx_License:_Xilinx.E2.80.99s_License_manager_looks_for_an_Ethernet_adapter_with_the_name_eth0...)
* [4] [USRP Hardware Driver and USRP Manual](https://files.ettus.com/manual/page_usrp_x3x0.html#x3x0_load_fpga_imgs)
* [5] [Ettus Research Videotutorial: introduction to RFNoC](https://www.youtube.com/watch?v=j-EfyPVpaJ8&t=1425s)

## Requirements
* Ubuntu OS 18.04
* GNU-Radio 3.7.13.4 (check your version by typing gnuradio-companion --version)
* UHD 3.14.0 (check your version by typing uhd_usrp_probe --version)
* gr-ettus
* Xilinx Vivado Vivado HLS 2017.4
* Python 2.7

## Installing Xilinx Vivado HLS 2017.4
Assuming you already have Ubuntu 18.04 installed the next is to install Xilinx Vivado, but first read carefully the **important previous steps below**.

### Previous steps
* #### **Set the shell**
In Ubuntu it is recommended to set the shell to `bash` by running the following commands in the terminal. Choose `No` when prompted by the first command and the second command will validate the that bash will be used.
~~~
sudo dpkg-reconfigure dash
ll /bin/sh
~~~
* #### **Set a eth0 network interface**
The Xilinx Vivado License Manager looks for an Ethernet adapter with the name `eth0`, so you must rename the ethernet adapter to `eth0` by following the steps below:
1. In the directory `/etc/udev/rules.d/` create a file `70-persistent-net.rules` by typing in a terminal:
~~~
sudo nano /etc/udev/rules.d/70-persistent-net.rules
~~~
2. Once inside the nano editor, paste the following code:
~~~
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="xx:xx:xx:xx:xx:xx", ATTR{dev_id}=="0x0", ATTR{type}=="1", NAME="eth0"
~~~
3. In the field `ATTR{address}` replace the **"xx:xx:xx:xx:xx:xx"** for your *MAC address*.
4. Save the file and exit.
5. By typing `ifconfig` you can check if the changes have been applied. If not, you have to reboot using the following commands:
~~~
ethtool -i <old_network_interface_name>
~~~
* Replace `<old_network_interface_name>` for the name of the current network interface.
* You will see the  driver number. Type the following code replacing `driver` for that number.
~~~
sudo modprobe -r <drive>
sudo udevadm control --reload-rules
sudo udevadm trigger
~~~
6. At this point you should be able to see the network interface named `eth0` by typing `ifconfig`.

### Installation steps
1. Go to the Xilinx official web, look for the 2017.4 version and download it.
2. Once the *sheel* is set up, go to the directory where the executable is, usually in `~/Downloads/Xilinx/Downloads/2017.4` and run the executable by typing `sudo ./xsetup`.
3. Select Vivado HL System Edition.
4. Be sure that Software Development Kit, Vivado Design Suite and DocNav are selected.
5. Install.

> **NOTE:**
> *the edition of Xilinx Vivado required for the X310 USRP is the Design Edition or System Edition.* 

### Activate license
1. Open the License Manager by typing `opt/Xilinx/Vivado/2017.4/bin/vlm`.
2. Click on ***Load License** an then on **Copy License** and select the license in the directory.

## Creating a development environment manually

The following sections show step by step how to install the UHD, GNU Radio and GR-Ettus modules. 

> **NOTE:** 
> *for a much more detailed tutorial we recommend to see the information in [[1](https://kb.ettus.com/Getting_Started_with_RFNoC_Development)] and [[2](https://kb.ettus.com/Building_and_Installing_the_USRP_Open-Source_Toolchain_(UHD_and_GNU_Radio)_on_Linux)] but keeping in mind that this project has been developed with the versions specified in the **Requirements** section.*

1. ### Install Python 2.7 and Git:
~~~
sudo apt install git
sudo apt install python
sudo apt install python-pip
~~~

2. ### Install and update dependencies:
**On ubuntu 18.04, type:**
~~~
sudo apt-get update
~~~
~~~
sudo apt-get -y install git swig cmake doxygen build-essential libboost-all-dev libtool libusb-1.0-0 libusb-1.0-0-dev libudev-dev libncurses5-dev libfftw3-bin libfftw3-dev libfftw3-doc libcppunit-1.14-0 libcppunit-dev libcppunit-doc ncurses-bin cpufrequtils python-numpy python-numpy-doc python-numpy-dbg python-scipy python-docutils qt4-bin-dbg qt4-default qt4-doc libqt4-dev libqt4-dev-bin python-qt4 python-qt4-dbg python-qt4-dev python-qt4-doc python-qt4-doc libqwt6abi1 libfftw3-bin libfftw3-dev libfftw3-doc ncurses-bin libncurses5 libncurses5-dev libncurses5-dbg libfontconfig1-dev libxrender-dev libpulse-dev swig g++ automake autoconf libtool python-dev libfftw3-dev libcppunit-dev libboost-all-dev libusb-dev libusb-1.0-0-dev fort77 libsdl1.2-dev python-wxgtk3.0 git libqt4-dev python-numpy ccache python-opengl libgsl-dev python-cheetah python-mako python-lxml doxygen qt4-default qt4-dev-tools libusb-1.0-0-dev libqwtplot3d-qt5-dev pyqt4-dev-tools python-qwt5-qt4 cmake git wget libxi-dev gtk2-engines-pixbuf r-base-dev python-tk liborc-0.4-0 liborc-0.4-dev libasound2-dev python-gtk2 libzmq3-dev libzmq5 python-requests python-sphinx libcomedi-dev python-zmq libqwt-dev libqwt6abi1 python-six libgps-dev libgps23 gpsd gpsd-clients python-gps python-setuptools
~~~
~~~
sudo apt-get install pyqt5-dev python-pyqt5
~~~
3. ### Building and installing UHD from source code:
* Create the rfnoc folder.
~~~
cd 
mkdir rfnoc
cd rfnoc
~~~

* Clone the repository.
~~~
git clone https://github.com/EttusResearch/uhd
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
~~~

* Include in .bashrc file
~~~
export LD_LIBRARY_PATH=/usr/local/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
~~~

4. ### Install GNU Radio
~~~
cd
cd rfnoc
git clone --recursive https://github.com/gnuradio/gnuradio
cd gnuradio
git checkout v3.7.13.4
git submodule update --init --recursive
mkdir build 
cd build
cmake -DENABLE_GR_UHD=ON ../
make -j 7
sudo make install 
sudo ldconfig
~~~
5. ### Install gr-ettus
~~~
cd
cd rfnoc
git clone -b maint-3.7 https://github.com/EttusResearch/gr-ettus.git 
cd gr-ettus
mkdir build 
cd build 
cmake ../
make -j 7
sudo make install
~~~

## Setup networking
> **NOTE:** in [4] you can see the full note on the Ettus official web about **setup networking**.
### Setting the USRP IP address

In the rear panel, the USRP X310 has 1G and 10 Gbe SFP+ ports for Ethernet interfaces named 0 and 1 respectively. When loading the default image, the IP configuration is as follows:
~~~
* 1 Gb: 192.168.10.2 (port 0)
* 10 Gbe: 192.168.40.2 (port 1)
~~~
Since each USRP must have a different IP, follow these steps to assign a specific IP:
1. Go to the directory:
`/usr/local/lib/uhd/utils`
2. Type the following command by replacing the current IP address on the **_CURRENT_IP_** field and add the new IP address on the **_NEW_IP_** field.
~~~
./usrp_burn_mb_eeprom --args="type=x300,addr=<CURRENT_IP>" --values="ip-addr3=<NEW_IP>"
~~~
3. Keep in mind that the key _ip-addr#_ is **ip_addr3** in this case because the aim is to set the port 1 like a 10 Gbe interface for a HG image. For more detalis see the apart **"Setup the host interface"** in [4].

4. Power-cycle the device before you can use the new IP address.

### Configuring the Socket Buffers
It is necessary to increase the maximum size of the socket buffers to avoid potential overflows and underruns at high sample rates. Add the following entries into /etc/sysctl.conf (root privileges required):
~~~
sudo sysctl -w net.core.rmem_max=33554432
sudo sysctl -w net.core.wmem_max=33554432
~~~

### Configuring the MTU
In order to achieve maximum performance, it is recommended to set the MTU size to 9000 for 10 GigE and 1500 for 1 GigE.  To set the MTU to 9000, you can use the following command:
~~~
sudo ifconfig <Netwotk_interface> mtu 9000 # For 10 GigE
sudo ifconfig <Network_interface> mtu 1500 # For 1 GigE
~~~

## Placing daughterboards
For this project were used basic Tx and basic Rx daughterboards that are capable of transmitting and receiving baseband IQ samples respectively. The assembly was carried out as shown in the following pictures:
### Basic TX
![Tx_basic](https://github.com/IMDEANetworksWNG/MISO/blob/main/Docs/Basic_tx.jpg)
### Basic RX
![Rx_basic](https://github.com/IMDEANetworksWNG/MISO/blob/main/Docs/basic_rx.jpg)

## Loading the default FPGA image to the transmitter
Ettus Research offers a defaul image which is pre-built with a set of RFNoC blocks. To get the default image, run the following command:
~~~
uhd_images_downloader
~~~
This defaul image contains the blocks:
~~~
* DmaFIFO_0
* Radio_0
* Radio_1
* DDC_0
* DDC_1
* DUC_0
* DUC_1
~~~ 