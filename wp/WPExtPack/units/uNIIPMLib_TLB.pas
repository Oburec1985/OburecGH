unit uNIIPMlib_TLB;


{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers.
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}
interface

uses Windows, ActiveX, Classes, Graphics, OleServer, StdVCL, Variants;


const
  // TypeLibrary Major and minor versions
  uNIIPMlibMajorVersion = 1;
  uNIIPMlibMinorVersion = 0;
  IID_INIIPM: TGUID = '{ADED7AEC-2818-4988-B3FF-788DBF76F723}';

implementation

uses ComObj;

end.

