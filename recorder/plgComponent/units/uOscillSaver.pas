unit uOscillSaver;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, uRecBasicFactory, inifiles,
  uEventList, //udrawobj,
  uComponentservises, uEventTypes, ComCtrls, uBtnListView, recorder,
  ucommonmath, MathFunction, uMyMath, //uTag,
  uaxis, upage, uBuffTrend1d, uQueue, uYCursor,
  uRecorderEvents, ubaseObj, uCommonTypes, uRCFunc,
  //uBuffTrend1d,
  tags,
  shellapi,
  uPathMng,
  uEditGraphFrm,
  uHardwareMath,
  PluginClass, ImgList, Menus, uSpin, uRcCtrls, Buttons;

procedure saveComData(ifile: TIniFile; sect:string; mf:string);
procedure savedata(dir: string; sname: string; db: array of double);
// заголовок сигнала
procedure saveHeader(ifile: TIniFile; Freq: double; start: double;
  ident: string; xUnits:string);

implementation

procedure saveComData(ifile: TIniFile; sect:string; mf:string);
begin
  ifile.WriteString(sect, mf, '');
end;

// данные сигнала
procedure savedata(dir: string; sname: string; db: array of double);
var
  lname: string;
  f: file;
begin
  // временной блок
  lname := dir + '\' + sname + '.dat';
  AssignFile(f, lname);
  Rewrite(f, 1);
  BlockWrite(f, db[0], sizeof(double) * length(db));
  closefile(f);
end;
// заголовок сигнала
procedure saveHeader(ifile: TIniFile; Freq: double; start: double;
  ident: string; xUnits:string);
begin
  WriteFloatToIniMera(ifile, ident, 'Freq', Freq);
  ifile.WriteString(ident, 'XFormat', 'R8');
  ifile.WriteString(ident, 'YFormat', 'R8');
  // Подпись оси x
  ifile.WriteString(ident, 'XUnits', xUnits);
  // Подпись оси Y
  // ifile.WriteString(s.tagname, 'YUnits', TagUnits(wp.m_YParam.tag));
  WriteFloatToIniMera(ifile, ident, 'Start', start);
  // k0
  ifile.WriteFloat(ident, 'k0', 0);
  // k1
  ifile.WriteFloat(ident, 'k1', 1);
  if xUnits='с' then
  begin
    ifile.WriteString(ident, 'Function', '1');
    ifile.WriteString(ident, 'XType', '5');
    // напряжение
    ifile.WriteString(ident, 'YType', '160');
    ifile.WriteString(ident, 'XUnitsId', '0x100000501');
    ifile.WriteString(ident, 'YUnitsId', '0x100003201');
  end;
end;

end.
