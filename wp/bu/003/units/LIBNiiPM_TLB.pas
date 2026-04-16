unit LIBNiiPM_TLB;

{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers.
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}
interface

uses Windows, ActiveX, Classes, Graphics, OleServer, StdVCL, Variants;


// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:
//   Type Libraries     : LIBID_xxxx
//   CoClasses          : CLASS_xxxx
//   DISPInterfaces     : DIID_xxxx
//   Non-DISP interfaces: IID_xxxx
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  LIBNiiPMMajorVersion = 1;
  LIBNiiPMMinorVersion = 0;

  LIBID_LIBNiiPM: TGUID = '{7F30E7E6-DAF8-459C-8FE9-A8142CCF6D97}';

  IID_INiiPM: TGUID = '{ADED7AEC-2818-4988-B3FF-788DBF76F723}';
  CLASS_NiiPm: TGUID = '{7CD5B8BD-4CD7-4350-813B-0896D3610CC7}';


implementation

uses ComObj;

end.

