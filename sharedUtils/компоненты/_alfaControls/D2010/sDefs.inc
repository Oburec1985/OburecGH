{ ---- Definitions by Serge V. Goncharov ---- }

// << 3rdparty support start <<
//{$DEFINE DEVEX2011}  // DevExpress, LookAndFeel.NativeStyle property must be False
//{$DEFINE DEVEX6}     // Old version of DevExpress components, earlier than v2011
//{$DEFINE USEPNG}     // Support of TPngImageList from PngComponents
//{$DEFINE TNTUNICODE} // Enable Unicode support by TntControls
// >> 3rdparty support finish >>

//{$DEFINE USEHINTMANAGER}
//{$DEFINE ADDWEBBROWSER}       // Support of the TWebBrowser (full AC sources needed)
//{$DEFINE DISABLEPREVIEWMODE}  // If key is enabled then preview code is excluded
//{$DEFINE NOWNDANIMATION}      // Disable animation effects for dialogs and forms
//{$DEFINE CHANGEFORMSINDESIGN} // Changing the forms colors in design-time
//{$DEFINE SKININDESIGN}        // Skin control in frames in design-time
//{$DEFINE ALITE}               // Free Lite Edition
//{$DEFINE NOACPNG}             // Do not use AlphaControls Png loader automatically
//{$DEFINE NOJPG}               // Jpegs will not be used
//{$DEFINE NOFONTSCALEPATCH}    // Disables the patch for systems with big fonts
//{$DEFINE FIXGRAPHERROR}       // Solves graphic problem in design-time (if exists)
//{$DEFINE ALITE} // Free Lite Edition

{$IFNDEF NOJPG}
//  {$DEFINE TINYJPG}
{$ENDIF}

//{$DEFINE NOSLOWDETAILS} // Simplified output without slow effects

{ ---- End defs by Serge V. Goncharov ---- }

{$DEFINE ALPHASKINS}

{$IFDEF VER310} {$DEFINE DELPHI_10BERLIN}{$ENDIF}
{$IFDEF VER300} {$DEFINE DELPHI_10}  {$ENDIF}
{$IFDEF VER290} {$DEFINE DELPHI_XE8} {$ENDIF}
{$IFDEF VER280} {$DEFINE DELPHI_XE7} {$ENDIF}
{$IFDEF VER270} {$DEFINE DELPHI_XE6} {$ENDIF}
{$IFDEF VER260} {$DEFINE DELPHI_XE5} {$ENDIF}
{$IFDEF VER250} {$DEFINE DELPHI_XE4} {$ENDIF}
{$IFDEF VER240} {$DEFINE DELPHI_XE3} {$ENDIF}
{$IFDEF VER230} {$DEFINE DELPHI_XE2} {$ENDIF}
{$IFDEF VER220} {$DEFINE DELPHI_XE}  {$ENDIF}
{$IFDEF VER210} {$DEFINE D2010}      {$ENDIF}
{$IFDEF VER200} {$DEFINE D2009}      {$ENDIF}
{$IFDEF VER185} {$DEFINE D2007}      {$ENDIF}
{$IFDEF VER180} {$DEFINE D2006}      {$ENDIF}
{$IFDEF VER170} {$DEFINE D2005}      {$ENDIF}
{$IFDEF VER150} {$DEFINE DELPHI7UP}  {$ENDIF}
{$IFDEF VER140} {$DEFINE DELPHI6UP}  {$ENDIF}
{$IFDEF VER130} {$DEFINE DELPHI5}    {$ENDIF}

{$IFDEF DELPHI_10BERLIN}{$DEFINE DELPHI_10}{$ENDIF}
{$IFDEF DELPHI_10}  {$DEFINE DELPHI_XE8} {$ENDIF}
{$IFDEF DELPHI_XE8} {$DEFINE DELPHI_XE7} {$ENDIF}
{$IFDEF DELPHI_XE7} {$DEFINE DELPHI_XE6} {$ENDIF}
{$IFDEF DELPHI_XE6} {$DEFINE DELPHI_XE5} {$ENDIF}
{$IFDEF DELPHI_XE5} {$DEFINE DELPHI_XE4} {$ENDIF}
{$IFDEF DELPHI_XE4} {$DEFINE DELPHI_XE3} {$ENDIF}
{$IFDEF DELPHI_XE3} {$DEFINE DELPHI_XE2} {$ENDIF}
{$IFDEF DELPHI_XE2} {$DEFINE DELPHI_XE}  {$ENDIF}
{$IFDEF DELPHI_XE}  {$DEFINE D2010}      {$ENDIF}
{$IFDEF D2010}      {$DEFINE D2009}      {$ENDIF}
{$IFDEF D2009}      {$DEFINE D2007}      {$ENDIF}
{$IFDEF D2007}      {$DEFINE D2006}      {$ENDIF}
{$IFDEF D2006}      {$DEFINE D2005}      {$ENDIF}
{$IFDEF D2005}      {$DEFINE DELPHI7UP}  {$ENDIF}
{$IFDEF DELPHI7UP}  {$DEFINE DELPHI6UP}  {$ENDIF}

{$IFDEF D2005}      {$DEFINE SPLASH}     {$ENDIF}

//{$IFNDEF BCB}
//  {$DEFINE SPLASH}
//{$ENDIF}

//{$WARNINGS OFF}

{$IFDEF DELPHI7UP}
  {$WARN UNIT_PLATFORM OFF}
  {$WARN SYMBOL_PLATFORM OFF}
  {$DEFINE CHECKXP}
{$ENDIF}

{$IFNDEF DELPHI6UP}
  {$UNDEF TNTUNICODE}
{$ENDIF}

{$IFDEF DELPHI7UP}
  {$WARN UNSAFE_CODE OFF}
  {$WARN UNSAFE_TYPE OFF}
  {$WARN UNSAFE_CAST OFF}
  {$IFDEF D2005}
    {$WARN SUSPICIOUS_TYPECAST OFF}
  {$ENDIF}
  {$IFDEF D2009}
    {$WARN IMPLICIT_STRING_CAST OFF}
    {$WARN IMPLICIT_STRING_CAST_LOSS OFF}
  {$ENDIF}
{$ENDIF}

{$DEFINE WARN_DEPRECATED} // Notify us about deprecated functions

{$IFDEF DELPHI6UP}
  {$IFDEF WARN_DEPRECATED}
    {$WARN SYMBOL_DEPRECATED ON}
  {$ENDIF}
{$ELSE}
  {$UNDEF WARN_DEPRECATED}
{$ENDIF}

{$IFDEF D2009}
  {$DEFINE WIDETEXT}
{$ENDIF}

{$IFDEF TNTUNICODE}
  {$DEFINE WIDETEXT}
{$ENDIF}

{$IFNDEF DELPHI6UP}
  {$UNDEF ADDWEBBROWSER} // WebBrowser does not exists in D5
{$ENDIF}

{$IFDEF DELPHI6UP}
  {$H+,A8} // Not supported in the D5
{$ENDIF}

{$IFNDEF BCB}
  {$DEFINE USEFILTEDIT}
{$ELSE}
  {$IFNDEF DELPHI_XE7}
    {$DEFINE USEFILTEDIT}
  {$ENDIF}
{$ENDIF}
{$B-}

//{$UNDEF USEFILTEDIT} // Uncomment this line if FiltEdit.obj is not found by compiler

{$IFDEF FPC}
  {$DEFINE WIN64}
  {$DEFINE NOMNUHOOK}
  {$DEFINE NOACPNG}
  {$mode Delphi}
{$ENDIF}