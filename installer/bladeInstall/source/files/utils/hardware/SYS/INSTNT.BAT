wdreg install
wdreg -name "kpccm2" install
wdreg -name "kpcc81" install
wdreg -name "kpe1pci" install
wdreg -name "kpmc011" install
wdreg -name "kpmc011p" install
wdreg -name "kpm2408" install
wdreg -name "kplc014" install
wdreg -inf %SYSTEMROOT%\system32\drivers\wd_virtual.inf loadinf
wdreg -inf %SYSTEMROOT%\system32\drivers\m2081cc.inf loadinf
wdreg -inf %SYSTEMROOT%\system32\drivers\m20100.inf loadinf
wdreg -inf %SYSTEMROOT%\system32\drivers\m2408.inf loadinf
