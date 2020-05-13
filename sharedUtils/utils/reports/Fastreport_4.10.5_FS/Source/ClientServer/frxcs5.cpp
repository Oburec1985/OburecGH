//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
USERES("frxcs5.res");
USEPACKAGE("vcl50.bpi");
USEUNIT("frxRegCS.pas");
USERES("frxRegCS.dcr");
USEPACKAGE("frx5.bpi");
USEPACKAGE("frxe5.bpi");
//---------------------------------------------------------------------------
#pragma package(smart_init)
//---------------------------------------------------------------------------

//   Package source.
//---------------------------------------------------------------------------

#pragma argsused
int WINAPI DllEntryPoint(HINSTANCE hinst, unsigned long reason, void*)
{
        return 1;
}
//---------------------------------------------------------------------------
