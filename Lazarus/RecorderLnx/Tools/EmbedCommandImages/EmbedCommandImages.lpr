program EmbedCommandImages;
{$mode objfpc}{$H+}
uses Interfaces, Classes, SysUtils, Forms, Controls, ImgList, LResources,
  uRecorderCommandImages;
type
  TClassFinder = class
    procedure FindClass(Reader: TReader; const AName: string;
      var AClass: TComponentClass);
  end;
procedure TClassFinder.FindClass(Reader: TReader; const AName: string;
  var AClass: TComponentClass);
begin
  if SameText(AName, 'TImageList') then AClass := TImageList;
end;
procedure Embed(const AFileName: string);
var
  I, S, F: Integer;
  L, O, W: TStringList;
  R, T: TStringStream;
  C: TComponent;
  Images: TImageList;
  Finder: TClassFinder;
begin
  L := TStringList.Create; O := TStringList.Create; W := TStringList.Create;
  C := nil; Finder := TClassFinder.Create;
  try
    L.LoadFromFile(AFileName);
    S := L.IndexOf('  object ilCommandButtons: TImageList');
    if S < 0 then raise Exception.Create('ilCommandButtons not found');
    F := S + 1;
    while (F < L.Count) and (L[F] <> '  end') do Inc(F);
    if F >= L.Count then raise Exception.Create('ilCommandButtons end not found');
    for I := S to F do O.Add(Copy(L[I], 3, MaxInt));
    RegisterClass(TImageList);
    R := TStringStream.Create(O.Text);
    try
      ReadComponentFromTextStream(R, C, @Finder.FindClass);
    finally
      R.Free;
    end;
    Images := TImageList(C);
    RegenerateRecorderDesignerIcons(Images);
    if Images.Count <> CRecorderCommandImageCount then
      raise Exception.CreateFmt('Unexpected image count: %d', [Images.Count]);
    T := TStringStream.Create('');
    try
      WriteComponentAsTextToStream(T, Images);
      W.Text := T.DataString;
    finally
      T.Free;
    end;
    for I := F downto S do L.Delete(I);
    for I := W.Count - 1 downto 0 do
      if W[I] <> '' then L.Insert(S, '  ' + W[I]);
    L.SaveToFile(AFileName);
  finally
    C.Free; Finder.Free; W.Free; O.Free; L.Free;
  end;
end;
begin
  Application.Initialize;
  if ParamCount <> 1 then
    raise Exception.Create('Usage: EmbedCommandImages <uMainForm.lfm>');
  Embed(ParamStr(1));
end.
