unit uOscIconIds;
{ Plugin-owned icon resource contract; no host ImageList or indices cross ABI.
  BuildOscImages regenerates the four embedded glyphs in this exact order. }
{$mode objfpc}{$H+}
interface
const
  OscIconLevel = 0;
  OscIconAutoRange = 1;
  OscIconXCursor = 2;
  OscIconLegend = 3;
  OscIconCount = 4;
implementation
end.
