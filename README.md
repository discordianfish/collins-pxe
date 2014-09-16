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

Now you can start the collins-pxe container and point it to collins:

    $ docker run --net host -e collins-pxe collins-host:9000 10.20.0.1/24 eth0

Since the container acts as a dhcp server, we need to use Docker's host networking (`-net host`).

If you need to pass custom config to banksman, you can set the BANKSMAN_OPT env variable.

# Configuration

For adding ipxe configurations, see
[banksman documentation](https://github.com/discordianfish/banksman#quick-start).
