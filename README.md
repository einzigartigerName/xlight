# xlight
This is an extremely simple and lightweight xbacklight alternative for x86_64 Linux.\
The installed file-size is less than 1.2kB.
### Usage
```bash
xlight [+-[0-1234]]
```

### Future
Goal is to further minimize the size of the binary.\
Although the performance is not to suffer, no focus will be placed on it.

### Install
To build this you need:
* lld - The LLVM Linker
* nsam

```bash
git clone https://github.com/einzigartigerName/xlight.git
cd xlight
make && sudo make install
```
It will auto-configured on build.\
There are also options for only installing the binary/man page (`install-bin`/`install-man`).

### Uninstall
```bash
sudo make uninstall
```
Options for only uninstalling the binary/man page are available (`uninstall-bin`/`uninstall-man`).