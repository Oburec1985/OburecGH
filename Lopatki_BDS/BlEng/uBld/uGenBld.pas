unit uGenBld;

interface
 uses
   Messages,classes,SysUtils,Windows,inifiles,math,comctrls;

 Type
  // ��������� ������ ���������� �� ������������� ������
  sBldSensor = record
    mChanNumber: short;      // ����� ������
    mAmplifier: byte;        // �������� ����
    mChanName: string;        // ����� ������
    mChanType: short;        // ��� �������
  end;

  // ��������� �������� ���������� ��� ���������� ��������� Bld �����
  sBldTitle = record
    mTitle:string;               // C������� ��������� - ������ "RecBld" ��� bld.
    mCardType:short;             // C������� ��� ����� 2070 ��� 2081.
    mChanNumber:short;           // ����� ����������� �������.
    mSensors:array of sBldSensor;// ������ �������� ����������� �������
    mTestDate:TDateTime;         // ���� ���������
    mSamplingFreq:short;         // ������� �������������
    mEmpty:array of char;        // ���������� �� 6���� ��������� ff
    mData:array of byte;         // ������
  end;

  // ���� ��� ������/ ������ Bld �����
  cBldFile = class
    mBldTitle:sBldtitle; // ������������ ���������� bld �����
    f:File;
  private
    // ��� �������� � ���������� f ������������� ����
    constructor Create(filename:string);
    // ���������� ���������� ����� ���������� ������ � Bld ����
    procedure Save;
    // �������� Bld ����� � ���� ������
    function Load:boolean;
  end;

implementation
constructor cBldFile.Create(filename:string);
begin
  AssignFile(F,FileName);
end;

procedure cBldFile.Save;
begin
  // ��������, ��� ���� ����������
  if Assigned(@f) then
  begin

  end;
end;

function cBldFile.Load:boolean;
  var lReaded,i:cardinal; // ����� ������� ��������� ����.
  // ��������������� ��������� ��� ������ ���-�� ������
  procedure readSensor(var sensor:sBldSensor);
  var
    Ch:char;
    iReaded:cardinal;
    bEndName:boolean;
  begin
    bEndName:=false;
    BlockRead(f,sensor.mChanNumber,2,iReaded);
    BlockRead(f,sensor.mAmplifier,2,iReaded);
    while not bEndName do
    begin
      BlockRead(f,Ch,1,iReaded);
      if Ch<>#0 then bEndName:=true
      else sensor.mChanName:=sensor.mChanName+Ch;
    end;
    BlockRead(f,sensor.mChanType,2,iReaded);
  end;
begin
  // ��������, ��� ���� ����������
  if Assigned(@f) then
  begin
  // ������� ������ ���������(6),��� �����(2) � ����� ��������(2)
    BlockRead(f,mBldTitle,10,lReaded);if mBldTitle.mTitle<>'RecBld' then exit;
    SetLength(mBldTitle.mSensors,mBldTitle.mChanNumber);
    for i:=0 to mBldTitle.mChanNumber-1 do readSensor(mBldTitle.mSensors[i]);
    BlockRead(f,mBldTitle.mTestDate,4,lReaded);
    BlockRead(f,mBldTitle.mSamplingFreq,2,lReaded);
  end;
end;

end.
