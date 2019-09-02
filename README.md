# xlight
This is an extremly simple and lightweight xbacklight alternative for x86_64 Linux.\
The installed file-size is less than 9kB.
### Usage
```bash
xlight [+-[0-1234]]
```

### Future
Goal is to further minimize the size of the binary.\
Although the performance is not to suffer, no focus will be placed on it.

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
