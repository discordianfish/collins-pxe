# collins-pxe

*automatically register system with collins and provide ipxe configs from asset attributes*

This Docker container uses dnsmasq to PXE chainload iPXE which gets its
config via [banksman](https://github.com/discordianfish/banksman) from
collins node attributes.


# Build it

As usual:

    $ sudo docker build -t collins-pxe .


# Starting things up

First you need to
[start a collins container](https://github.com/discordianfish/collins/blob/dockerize/DOCKER.md).
This example expects your container to be called `collins-server`.

Now you can start the collins-pxe container and link against the
collins container:

    $ ID=$(sudo docker run -i -t -link collins-server:collins collins-pxe)

Since the container acts as a dhcp server, we're using
[pipework](https://github.com/jpetazzo/pipework) to create a new
interface within the container:

    $ pipework br0 $ID 192.168.242.1/24

*You can use whatever network you prefer*

Now the container is serving DHCP requests on br0. If you want to offer
DHCP on your host's ethernet, you need to add eth0 to your bridge:

    $ brctl addif br0 eth0

For more details, see @jpetazzo's article on
[Network booting machines with a PXE server running in a Docker container](http://jpetazzo.github.io/2013/12/07/pxe-netboot-docker/).


# Configuration

For adding ipxe configurations, see
[banksman documentation](https://github.com/discordianfish/banksman#quick-start).


# Status

This is work in progress and never installed an actual system. So take
it as a example or implementation idea.
