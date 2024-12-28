@echo off
if %1:==: goto aide
call edithlp ndx4_%1 idf_hlp
goto fin
:aide
echo DOHLP langue
echo ÿ
echo avec langue = { F, GB, I, G, ...}
:fin

