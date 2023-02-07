# lily-starter

An opinionated Terraform module to deploy Lily on the Google Cloud Platform.

## Caveat

Configuring non-boot attached disks is not included. For the disk to automatically mount on VM restarts, [read the docs](https://cloud.google.com/compute/docs/disks/add-persistent-disk#configuring_automatic_mounting_on_vm_restart).
