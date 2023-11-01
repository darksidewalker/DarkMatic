## Remove all unneeded files and folders from the Kernel in the following locations:
```
ls -la /boot
```
```
sudo rm -rf /boot/<name>
```
```
ls -la /lib/modules
```
```
sudo rm -rf /lib/modules/<name>
```
```
ls -la /etc/mkinitcpio.d/
```
```
sudo rm /etc/mkinitcpio.d/<name>
```
## Rebuild images
```
sudo mkinitcpio -P 
```

Reboot.
