//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("frxcs4.res");
USEPACKAGE("vcl40.bpi");
USEUNIT("frxRegCS.pas");
USERES("frxRegCS.dcr");
USEPACKAGE("frx4.bpi");
USEPACKAGE("frxe4.bpi");
//---------------------------------------------------------------------------
#pragma package(smart_init)
//---------------------------------------------------------------------------
//   Package source.
//---------------------------------------------------------------------------
int WINAPI DllEntryPoint(HINSTANCE hinst, unsigned long reason, void*)
{
        return 1;
}
//---------------------------------------------------------------------------
