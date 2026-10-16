unit ufrm_value;

{$mode ObjFPC}{$H+}{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, LazUTF8,
  FrameSettings, ModbusDevice, UCommon, tags, resstr, uUpdatable;

type

  { TFrm_Value }

  TFrm_Value = class(TFrameSettings)
    chbContiniousWrite: TCheckBox;
    chbGroupWrite: TCheckBox;
    chbImidiateWr: TCheckBox;
    cbType: TComboBox;
    cbMemoryRegion: TComboBox;
    cbByteOrder: TComboBox;
    EdAdr: TEdit;
    edName: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    memDescr: TMemo;
    rbRead: TRadioButton;
    rbWrite: TRadioButton;
    rbReadWrite: TRadioButton;
    procedure cbByteOrderKeyPress(Sender: TObject; var Key: Char);
    procedure cbMemoryRegionKeyPress(Sender: TObject; var Key: Char);
    procedure cbTypeKeyPress(Sender: TObject; var Key: Char);
    procedure chbContiniousWriteClick(Sender: TObject);
    procedure EdAdrKeyPress(Sender: TObject; var Key: Char);
  private
    fTag: TModbusTag;
    fTagNameChanged: TNameChangeEvent;
    fDescrChanged: TDescrChangeEvent;


    procedure doTagNameChanged(oldname, newname: string);
    procedure doDescrChanged(namestr, newdescr: string);

    function GetTag: TModbusTag;
    procedure SetTag(const Value: TModbusTag);


    { Private declarations }
  public
    { Public declarations }
    procedure InitComboBoxes;
    procedure UpdateHmi; override;
    procedure ApplySettings; override;
    property ModbusTag: TModbusTag read GetTag write SetTag;
    property OnTagNameChanged: TNameChangeEvent read fTagNameChanged write fTagNameChanged;
    property OnDescrChanged: TDescrChangeEvent read fDescrChanged write fDescrChanged;
  end;

var
  frm_value: Tfrm_value;

implementation

{$R *.lfm}

procedure TFrm_Value.doTagNameChanged(oldname, newname: string);
begin
  if Assigned(fTagNameChanged) then
     fTagNameChanged(Self, oldname, newname);
end;

procedure TFrm_Value.doDescrChanged(namestr, newdescr: string);
begin
  if Assigned(fDescrChanged) then
     fDescrChanged(Self, namestr, newdescr);
end;

procedure TFrm_Value.EdAdrKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  //Распознание ввода hex

  //Если нажатая клавиша не цифра
  if not (key in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', #8]) and
  //Проверяем ноль ли первый символ строки 0, разрешаем ввод "x"
  not ((length(edAdr.Text) = 1) and (edAdr.Text[1] = '0') and (Key = 'x')) and
  //Если строка начинается с 0x то можно вводить буквы шестнадцатиричного числа
  not ((pos('0x', edAdr.Text) = 1) and (Key in ['a', 'A', 'b', 'B', 'c', 'C', 'd', 'D', 'e', 'E', 'f', 'F'])) then
     Key := Char(0);
end;

function TFrm_Value.GetTag: TModbusTag;
begin
  result := fTag;
end;

procedure TFrm_Value.cbByteOrderKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  Key := Char(0);
end;

procedure TFrm_Value.cbMemoryRegionKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  Key := Char(0);
end;

procedure TFrm_Value.cbTypeKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  Key := Char(0);
end;

procedure TFrm_Value.chbContiniousWriteClick(Sender: TObject);
begin
  inherited;
  //fTag.ContiniousWrite := chbContiniousWrite.Checked;
end;



procedure TFrm_Value.SetTag(const Value: TModbusTag);
var
  k: boolean;
  byteorder: integer;
begin
  fTag := Value;

  if cbType.Items.Count = 0 then
     begin
       InitComboBoxes;
     end;

  if Assigned(fTag) then
    begin
    //edName.Text := WinCPToUTF8(fTag.Name);
    //memDescr.Text := WinCPToUTF8(fTag.Description);

    edName.Text := fTag.Name;
    memDescr.Text := fTag.Description;

    edAdr.Text := inttostr(fTag.Addres);
    cbType.ItemIndex := Integer(fTag.DataType);
    chbContiniousWrite.Checked := fTag.ContiniousWrite;
    cbMemoryRegion.ItemIndex := Integer(fTag.MemRegion);
    byteorder := Integer(fTag.ByteOrder);
    if byteorder < 0 then byteorder := 0;
    cbByteOrder.ItemIndex := byteorder;
    chbImidiateWr.Checked := fTag.ImidiateWrite;
    k := fTag.AllowGroupWorking;
    chbGroupWrite.Checked := k;
    if fTag.AccessType = atRead then rbRead.Checked := true else
    if fTag.AccessType = atWrite then rbWrite.Checked := true else
    if fTag.AccessType = atReadWrite then rbReadWrite.Checked := true;
    end;
end;


procedure TFrm_Value.InitComboBoxes;
begin
  cbType.Clear;
  cbType.Items.Add('Bool');
  cbType.Items.Add('Int16');
  cbType.Items.Add('Int32');
  cbType.Items.Add('UInt16');
  cbType.Items.Add('UInt32');
  cbType.Items.Add('Single');
  cbType.Items.Add('Double');
  cbType.ItemIndex := 0;

  cbMemoryRegion.Clear;
  cbMemoryRegion.Items.Add('Holding');
  cbMemoryRegion.Items.Add('Input');
  cbMemoryRegion.Items.Add('Coils');
  cbMemoryRegion.ItemIndex := 0;

  cbByteOrder.Clear;
  cbByteOrder.Items.Add(rsBigEndian);
  cbByteOrder.Items.Add(rsGrandWord);
  cbByteOrder.Items.Add(rsGrandDoubleWord);
  cbByteOrder.Items.Add(rsReverse);
  cbByteOrder.Items.Add(rsNoCorrection);
  cbByteOrder.ItemIndex := 0;
end;

procedure TFrm_Value.UpdateHmi;
begin
  SetTag(self.fTag);
end;

procedure TFrm_Value.ApplySettings;
var
  Different: boolean;
  oldname: string;
begin
  if edAdr.Text = '' then
  begin
    ShowMessage(rsEmptyAdress);
    exit;
  end;

  if not Assigned(fTag) then Exit;
  oldname := fTag.Name;

  Different := edName.Text <> fTag.Name;
  fTag.Name := edName.Text;

  if Different then doTagNameChanged(UTF8ToWinCP(oldname), UTF8ToWinCP(fTag.Name));

  Different := memDescr.Text <> fTag.Description;
  fTag.Description := memDescr.Text;

  if Different then doDescrChanged(UTF8ToWinCP(fTag.Name), fTag.Description);


  //Доступ к тегу (чтение, запись, чтение и запись)
  if rbRead.Checked then fTag.AccessType := atRead else
  if rbWrite.Checked then fTag.AccessType := atWrite else
  if rbReadWrite.Checked then fTag.AccessType := atReadWrite;
  DoTypeChanged;

  //fTag.Description := memDescr.Text;
  fTag.Addres := strtoint(edAdr.Text);

  EdAdr.Text := inttostr(fTag.Addres);

  fTag.DataType := TDataType(cbType.ItemIndex);
  fTag.MemRegion := TMemRegion(cbMemoryRegion.ItemIndex);
  fTag.ByteOrder := TByteOrder(cbByteOrder.ItemIndex);
  fTag.ContiniousWrite := chbContiniousWrite.Checked;
  fTag.AllowGroupWorking := chbGroupWrite.Checked;
  fTag.ImidiateWrite := chbImidiateWr.Checked;
end;

end.

