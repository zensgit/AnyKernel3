### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=Wild Kernels by TheWildJames aka Morgan Weedman
do.devicecheck=0
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
device.name1=
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties


### AnyKernel install
## boot shell variables
block=boot
is_slot_device=auto
ramdisk_compression=auto
patch_vbmeta_flag=auto
no_magisk_check=1

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh

kernel_version=$(cat /proc/version | awk -F '-' '{print $1}' | awk '{print $3}')
case $kernel_version in
    5.1*) ksu_supported=true ;;
    6.1*) ksu_supported=true ;;
    6.6*) ksu_supported=true ;;
    6.12*) ksu_supported=true ;;
    *) ksu_supported=false ;;
esac

ui_print " " "  -> Wild Kernels Supported: $ksu_supported"
$ksu_supported || abort "  -> Non-GKI device, abort."

device_sku=$(getprop ro.boot.product.hardware.sku 2>/dev/null)
[ "$device_sku" ] || device_sku=$(grep -o 'androidboot.product.hardware.sku=[^ ]*' /proc/cmdline 2>/dev/null | cut -d= -f2)
[ "$device_sku" ] || device_sku=$(grep -o 'androidboot.hardware.sku=[^ ]*' /proc/cmdline 2>/dev/null | cut -d= -f2)

derive_nezha_kernel_only_payload() {
  local derive_dir unpack_dir derive_img
  derive_img="$AKHOME/boot-nezha-derive.img"
  derive_dir="$AKHOME/.nezha-derive"
  unpack_dir="$AKHOME/.nezha-unpack"

  rm -rf "$derive_dir" "$unpack_dir" "$derive_img"
  mkdir -p "$derive_dir" "$unpack_dir"
  cp -af "$SPLITIMG"/. "$derive_dir"/
  cp -f "$AKHOME/Image" "$derive_dir/kernel"
  rm -f "$derive_dir/kernel_dtb"

  (
    cd "$derive_dir" &&
    magiskboot repack "$BOOTIMG" "$derive_img" >/dev/null
  ) || abort "  -> Failed to derive Nezha kernel-only payload."

  (
    cd "$unpack_dir" &&
    magiskboot unpack -h "$derive_img" >/dev/null
  ) || abort "  -> Failed to unpack derived Nezha payload."

  [ -f "$unpack_dir/kernel" ] || abort "  -> Missing derived Nezha kernel payload."
  cp -f "$unpack_dir/kernel" "$AKHOME/Image"

  rm -rf "$derive_dir" "$unpack_dir" "$derive_img"
}

# boot install
split_boot
if [ "$kernel_version" = "6.12.23" ] && [ "$device_sku" = "nezha" ] && [ -f "$AKHOME/Image" ] && [ -f "$SPLITIMG/kernel_dtb" ]; then
    ui_print " "
    ui_print "Nezha 6.12 detected; deriving kernel-only payload"
    ui_print "and preserving stock kernel_dtb for final repack..."
    derive_nezha_kernel_only_payload
fi
if [ -f "split_img/ramdisk.cpio" ]; then
    unpack_ramdisk
    write_boot
else
    flash_boot
fi

ui_print " "
ui_print "WildKernels Telegram Channel:"
ui_print "https://t.me/WildKernels"
ui_print " "
ui_print "WildKernels Website:"
ui_print "https://wildkernels.dev"
ui_print " "
ui_print "Wild_KSU GitHub Repository:"
ui_print "https://github.com/WildKernels/Wild_KSU"
ui_print "KernelSU-Next fork focused on customization and root-hiding features!"
ui_print " "
ui_print "GKI_KernelSU_SUSFS GitHub Repository:"
ui_print "https://github.com/WildKernels/GKI_KernelSU_SUSFS"
ui_print "GKI kernels with KernelSU and SUSFS."
ui_print " "
ui_print "OnePlus_KernelSU_SUSFS GitHub Repository:"
ui_print "https://github.com/WildKernels/OnePlus_KernelSU_SUSFS"
ui_print "OnePlus kernels with KernelSU and SUSFS."
ui_print " "
ui_print "Samsung_KernelSU_SUSFS GitHub Repository:"
ui_print "https://github.com/WildKernels/Samsung_KernelSU_SUSFS"
ui_print "Samsung kernels with KernelSU and SUSFS."
ui_print " "
