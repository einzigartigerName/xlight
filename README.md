# xlight
This is an extremly simple and lightweight xbacklight alternative for x86_64 Linux.\
The installed file-size is less than 10kB.
### Usage
```bash
xlight [+-[0-1234]]
```

### Install
To build this you need:
* ld - The GNU linker
* nsam

```bash
git clone https://github.com/einzigartigerName/xlight.git
cd xlight
make && sudo make install
```
It will auto-configured on build

### Uninstall
```bash
sudo make uninstall
```