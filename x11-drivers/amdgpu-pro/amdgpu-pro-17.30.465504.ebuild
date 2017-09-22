# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

MULTILIB_COMPAT=( abi_x86_{32,64} )
inherit eutils multilib-build unpacker

DESCRIPTION="Ati precompiled drivers for Radeon Evergreen (HD5000 Series) and newer chipsets"
HOMEPAGE="http://support.amd.com/en-us/kb-articles/Pages/AMDGPU-PRO-Driver-for-Linux-Release-Notes.aspx"
BUILD_VER=17.30-465504
BUILD_SUBVER=2.4.70-465504
ROCR_VER=1.1.5-465504
ROCT_VER=1.0.6-465504
VDPAU_VER=17.0.1-465504
X11_VIDEO_VER=1.3.99-465504
#X11_VER=1.19.0-465504

SRC_URI="https://www2.ati.com/drivers/linux/ubuntu/${PN}-${BUILD_VER}.tar.xz"

RESTRICT="fetch strip"

IUSE="gles2 opencl +opengl vdpau +vulkan radeon +rocm +rocr +roct"

LICENSE="AMD GPL-2 QPL-1.0"
KEYWORDS="~amd64 ~x86"
SLOT="1"

RDEPEND="
	>=app-eselect/eselect-opengl-1.0.7
	app-eselect/eselect-opencl
	sys-kernel/amdgpu-pro-dkms
	x11-libs/libX11[${MULTILIB_USEDEP}]
	x11-libs/libXext[${MULTILIB_USEDEP}]
	x11-libs/libXinerama[${MULTILIB_USEDEP}]
	x11-libs/libXrandr[${MULTILIB_USEDEP}]
	x11-libs/libXrender[${MULTILIB_USEDEP}]
	vulkan? (
		media-libs/vulkan-base
	)
	!x11-drivers/ati-drivers
"

DEPEND="${RDEPEND}
	x11-proto/inputproto
	x11-proto/xf86miscproto
	x11-proto/xf86vidmodeproto
	x11-proto/xineramaproto
"

S="${WORKDIR}"

pkg_nofetch() {
	einfo "Please download"
	einfo "  - ${PN}-${BUILD_VER}.tar.xz" for Ubuntu 16.04.3
	einfo "from ${HOMEPAGE} and place them in ${DISTDIR}"
}

unpack_deb() {
	echo ">>> Unpacking ${1##*/} to ${PWD}"
	unpack $1
	unpacker ./data.tar*

	# Clean things up #458658.  No one seems to actually care about
	# these, so wait until someone requests to do something else ...
	rm -f debian-binary {control,data}.tar*
}

pkg_pretend() {
	local CONFIG_CHECK="~MTRR ~!DRM ACPI PCI_MSI \
		!LOCKDEP !PAX_KERNEXEC_PLUGIN_METHOD_OR \
		~!DRM_AMDGPU ~!DRM_AMDGPU_USERPTR"
	use amd64 && CONFIG_CHECK+=" COMPAT"

	local ERROR_MTRR="CONFIG_MTRR required for direct rendering."
	local ERROR_DRM="CONFIG_DRM must be disabled or compiled as a
		module and not loaded for direct rendering to work."
	local ERROR_DRM_AMDGPU="CONFIG_DRM_AMDGPU should be enabled or compiled as
	module."	
	local ERROR_DRM_AMDGPU_USERPTR="CONFIG_DRM_AMDGPU_USERPTR should be
	enabled."
	local ERROR_BKL="CONFIG_BKL must be enabled for kernels 2.6.37-2.6.38."
}

src_install() {
	default

	unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/amdgpu-pro-core_${BUILD_VER}_all.deb"
	#unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/amdgpu-pro-graphics_${BUILD_VER}_amd64.deb"

	rm -rf ${S}/lib

    if use rocm ; then 
	    if use amd64 ; then
	    	unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/rocm-amdgpu-pro-opencl-dev_${BUILD_VER}_amd64.deb"
    		unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/rocm-amdgpu-pro-opencl_${BUILD_VER}_amd64.deb"
    		unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/rocm-amdgpu-pro-icd_${BUILD_VER}_amd64.deb"
    		unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/rocm-amdgpu-pro_${BUILD_VER}_amd64.deb"
		fi	
	fi

    if use rocr ; then 
	    if use amd64 ; then
		    unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/rocr-amdgpu-pro-dev_${ROCR_VER}_amd64.deb"
    		unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/rocr-amdgpu-pro_${ROCR_VER}_amd64.deb"
		fi	
	fi

    if use roct ; then 
	    if use amd64 ; then
    		unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/roct-amdgpu-pro-dev_${ROCT_VER}_amd64.deb"
	    	unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/roct-amdgpu-pro_${ROCT_VER}_amd64.deb"
		fi	
	fi

    ## Remove symlink to nonexistent point
    if use amd64 ; then
        rm -rf ${S}/usr/lib64/opengl/amdgpu-pro/lib/libdrm_radeon.so
	fi

    if use x86 ; then
        rm -rf ${S}/usr/lib32/opengl/amdgpu-pro/lib/libdrm_radeon.so
	fi

	if use radeon ; then
	     if use amd64 ; then
		     dosym /usr/lib64/opengl/amdgpu-pro/lib/libdrm_radeon.so.1.0.1 /usr/lib64/opengl/amdgpu-pro/lib/libdrm_radeon.so
		 fi	 

		 if use x86 ; then
		     dosym /usr/lib32/opengl/amdgpu-pro/lib/libdrm_radeon.so.1.0.1 /usr/lib32/opengl/amdgpu-pro/lib/libdrm_radeon.so
		 fi	 
    fi

	if use opencl ; then # Check opencl
		if use amd64 ; then
			unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/clinfo-amdgpu-pro_${BUILD_VER}_amd64.deb"


			unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/libopencl1-amdgpu-pro_${BUILD_VER}_amd64.deb"
			unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/opencl-amdgpu-pro-icd_${BUILD_VER}_amd64.deb"

			dodir "/usr/lib64/OpenCL/vendors/amdgpu-pro"
			cp -d ${S}/opt/amdgpu-pro/lib/x86_64-linux-gnu/* ${D}/usr/lib64/OpenCL/vendors/amdgpu-pro

			echo "/usr/lib64/OpenCL/vendors/amdgpu-pro/libamdocl64.so" > ${S}/etc/OpenCL/vendors/amdocl64.icd
		fi
		
		if use x86 ; then
    		unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/libopencl1-amdgpu-pro_${BUILD_VER}_i386.deb"
	    	unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/opencl--amdgpu-pro-icd_${BUILD_VER}_i386.deb"

		    dodir "/usr/lib32/OpenCL/vendors/amdgpu-pro"
    		cp -d ${S}/opt/amdgpu-pro/lib/i386-linux-gnu/* ${D}/usr/lib32/OpenCL/vendors/amdgpu-pro

	    	echo "/usr/lib32/OpenCL/vendors/amdgpu-pro/libamdocl32.so" > ${S}/etc/OpenCL/vendors/amdocl32.icd
        fi 

		chmod -x ${S}/etc/OpenCL/vendors/*
		rm -rf ${S}/usr/lib
	fi

	if use vulkan ; then
		if use amd64 ; then
			unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/vulkan-driver-amdgpu-pro_${BUILD_VER}_amd64.deb"

			dodir "/usr/lib64/vulkan/amdgpu-pro"
			cp -d ${S}/opt/amdgpu-pro/lib/x86_64-linux-gnu/* ${D}/usr/lib64/vulkan/amdgpu-pro
			sed -i 's|/opt/amdgpu-pro/lib/x86_64-linux-gnu|/usr/lib64/vulkan/amdgpu-pro|g' ${S}/etc/vulkan/icd.d/amd_icd64.json
		fi
	
    	if use x86 ; then
     	    unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/vulkan-driver-amdgpu-pro_${BUILD_VER}_i386.deb"

	    	dodir "/usr/lib32/vulkan/amdgpu-pro"
		    cp -d ${S}/opt/amdgpu-pro/lib/i386-linux-gnu/* ${S}/usr/lib32/vulkan/amdgpu-pro
     		sed -i 's|/opt/amdgpu-pro/lib/i386-linux-gnu|/usr/lib32/vulkan/amdgpu-pro|g' ${S}/etc/vulkan/icd.d/amd_icd32.json
        fi

		chmod -x ${S}/etc/vulkan/icd.d/*
		rm -rf ${S}/usr/lib
	fi

	if use opengl ; then
		if use amd64 ; then
			unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/libgl1-amdgpu-pro-dri_${BUILD_VER}_amd64.deb"
			unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/libgl1-amdgpu-pro-glx_${BUILD_VER}_amd64.deb"

			dodir "/usr/lib64/opengl/amdgpu-pro/lib"
			cp -dR ${S}/opt/amdgpu-pro/lib/x86_64-linux-gnu/* ${D}/usr/lib64/opengl/amdgpu-pro/lib
			dodir "/usr/lib64/dri"
			cp -dR ${S}/usr/lib/x86_64-linux-gnu/dri/* ${D}/usr/lib64/dri
		fi

        if use x86 ; then
		    unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/libgl1-amdgpu-pro-dri_${BUILD_VER}_i386.deb"
		    unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/libgl1-amdgpu-pro-glx_${BUILD_VER}_i386.deb"

		    dodir "/usr/lib32/opengl/amdgpu-pro/lib"
		    cp -dR ${S}/opt/amdgpu-pro/lib/i386-linux-gnu/* ${D}/usr/lib32/opengl/amdgpu-pro/lib
		    dodir "/usr/lib32/dri"
		    cp -dR ${S}/usr/lib/i386-linux-gnu/dri/* ${D}/usr/lib32/dri
        fi

		rm -rf ${S}/usr/lib
	fi

	if use gles2 ; then
		if use amd64 ; then
			unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/libgles2-amdgpu-pro_${BUILD_VER}_amd64.deb"

			dodir "/usr/lib64/opengl/amdgpu-pro/lib"
			cp -d ${S}/opt/amdgpu-pro/lib/x86_64-linux-gnu/* ${D}/usr/lib64/opengl/amdgpu-pro/lib
		fi

		if use x86 ; then
     		unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/libgles2-amdgpu-pro_${BUILD_VER}_i386.deb"

	    	dodir "/usr/lib32/opengl/amdgpu-pro/lib"
		    cp -d ${S}/opt/amdgpu-pro/lib/i386-linux-gnu/* ${D}/usr/lib32/opengl/amdgpu-pro/lib
        fi

		rm -rf ${S}/usr/lib
	fi

	if use vdpau ; then
		if use amd64 ; then
			unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/libvdpau-amdgpu-pro_${VDPAU_VER}_amd64.deb"

			dodir "/usr/lib64/vdpau"
			cp -d ${S}/opt/amdgpu-pro/lib/x86_64-linux-gnu/vdpau/* ${D}/usr/lib64/vdpau
		fi

		if use x86 ; then
    		unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/libvdpau-amdgpu-pro_${VDPAU_VER}_i386.deb"

			dodir "/usr/lib32/vdpau"
			cp -d ${S}/opt/amdgpu-pro/lib/i386-linux-gnu/vdpau/* ${D}/usr/lib32/vdpau
		fi
	    	rm -rf ${S}/usr/lib
	fi

	if use amd64 ; then 
		unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/libdrm-amdgpu-pro-amdgpu1_${BUILD_SUBVER}_amd64.deb"
		unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/libdrm-amdgpu-pro-dev_${BUILD_SUBVER}_amd64.deb"
		unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/libdrm2-amdgpu-pro_${BUILD_SUBVER}_amd64.deb"
		unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/libegl1-amdgpu-pro_${BUILD_VER}_amd64.deb"
		unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/libgbm1-amdgpu-pro-dev_${BUILD_VER}_amd64.deb"
		unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/libgbm1-amdgpu-pro_${BUILD_VER}_amd64.deb"
		unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/xserver-xorg-video-amdgpu-pro_${X11_VIDEO_VER}_amd64.deb"

		cp -dR ${S}/opt/amdgpu-pro/lib/xorg/* ${D}/usr/lib64/xorg/

		rm -r ${S}/opt/amdgpu-pro/lib/xorg

	    dodir "/usr/lib64/opengl/amdgpu-pro/lib"
		dodir "/etc/X11/xorg.conf.d"
		
		cp -d ${S}/opt/amdgpu-pro/lib/x86_64-linux-gnu/gbm/* ${D}/usr/lib64/opengl/amdgpu-pro/lib
		cp -d ${S}/opt/amdgpu-pro/lib/x86_64-linux-gnu/*     ${D}/usr/lib64/opengl/amdgpu-pro/lib
		#cp -d ${S}/usr/share/X11/xorg.conf.d/*               ${D}/etc/X11/xorg.conf.d/
		cp ${FILESDIR}/10-amdgpu-pro.conf					 ${D}/etc/X11/xorg.conf.d/

		#rm -rf ${S}/usr/share/X11
	fi

	if use x86 ; then
    	unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/libdrm-amdgpu-pro-amdgpu1_${BUILD_SUBVER}_i386.deb"
	    unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/libdrm-amdgpu-pro-dev_${BUILD_SUBVER}_i386.deb"
    	unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/libdrm2-amdgpu-pro_${BUILD_SUBVER}_i386.deb"
    	unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/libegl1-amdgpu-pro_${BUILD_VER}_i386.deb"
    	unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/libgbm1-amdgpu-pro-dev_${BUILD_VER}_i386.deb"
    	unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/libgbm1-amdgpu-pro_${BUILD_VER}_i386.deb"
		unpack_deb "${S}/amdgpu-pro-${BUILD_VER}/xserver-xorg-video-amdgpu-pro_${X11_VIDEO_VER}_i386.deb"

		cp -dR ${S}/opt/amdgpu-pro/lib/xorg/* ${D}/usr/lib32/xorg/

		rm -r ${S}/opt/amdgpu-pro/lib/xorg

	    dodir "/usr/lib32/opengl/amdgpu-pro/lib"
		dodir "/etc/X11/xorg.conf.d"
		
    	cp -d ${S}/opt/amdgpu-pro/lib/i386-linux-gnu/gbm/* ${D}/usr/lib32/opengl/amdgpu-pro/lib
    	cp -d ${S}/opt/amdgpu-pro/lib/i386-linux-gnu/*     ${D}/usr/lib32/opengl/amdgpu-pro/lib
		#cp -d ${S}/usr/share/X11/xorg.conf.d/*             ${D}/etc/X11/xorg.conf.d/
		cp ${FILESDIR}/10-amdgpu-pro.conf				   ${D}/etc/X11/xorg.conf.d/

		#rm -rf ${S}/usr/share/X11
	fi

    rm -rf ${S}/usr/lib

	rm -rf ${S}/amdgpu-pro-${BUILD_VER}

	# Hack for libGL.so hardcoded directory path for amdgpu_dri.so
	if use amd64 ; then
		dodir "/usr/lib/x86_64-linux-gnu/dri"
		dosym /usr/lib64/dri/amdgpu_dri.so /usr/lib/x86_64-linux-gnu/dri/amdgpu_dri.so
	fi

	if use x86 ; then
    	dodir "/usr/lib/i386-linux-gnu/dri"
	    dosym /usr/lib32/dri/amdgpu_dri.so /usr/lib/i386-linux-gnu/dri/amdgpu_dri.so

	fi

    rm -rf ${S}/opt/
	cp -dR -t "${D}" * || die "Install failed!"
}

pkg_postinst() {
	elog "To switch to AMD OpenGL, run \"eselect opengl set amdgpu-pro\""
	elog
	elog "To build driver module run \"dkms install -m amdgpu-pro -v amdgpu-pro-${BUILD_VER}\" "
	elog
	elog "Fully rebooting the system after an ${PN} update is recommended"
	elog "Stopping Xorg, reloading amdgpu-pro kernel module and restart Xorg"
	elog "might not work"
	elog
	elog "Some cards need acpid running to handle events"
	elog "Please add it to boot runlevel with rc-update add acpid boot"
	elog

}
