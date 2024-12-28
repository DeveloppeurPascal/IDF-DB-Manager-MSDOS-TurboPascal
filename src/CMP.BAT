@echo off
set code=ndx4
del *.tpu
bpc index4
mkmsg index4.txt index4.msg
lha a c:\olf_soft\lzh\%code% index4.exe index4.msg *.hlp setup.cfg c:\prg\others\divers\setdflt.exe
set code=
echo on
