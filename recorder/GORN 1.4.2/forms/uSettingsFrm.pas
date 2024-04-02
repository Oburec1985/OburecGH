unit uSettingsFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, uMainFrm, ExtCtrls, Buttons, tags, uMyRecorderUtils,
  Spin, IniFiles;

type
  TSettingsFrm = class(TForm)
    BitBtn_Apply: TBitBtn;
    BitBtn_Cancel: TBitBtn;
    ButtonGornName: TButton;
    GroupBox1: TGroupBox;
    ListViewTermo: TListView;
    ButtonAddTermo: TButton;
    ButtonDeleteTermo: TButton;
    LabeledEditGornName: TLabeledEdit;
    LabeledEditTOFF: TLabeledEdit;
    LabeledEditTON: TLabeledEdit;
    GroupBox3: TGroupBox;
    LabeledEdit_IMax: TLabeledEdit;
    LabeledEdit_UMax: TLabeledEdit;
    LabeledEdit_PMax: TLabeledEdit;
    GroupBox_PID_Config: TGroupBox;
    LabeledEdit_PID_P: TLabeledEdit;
    LabeledEdit_PID_I: TLabeledEdit;
    LabeledEdit_PID_D: TLabeledEdit;
    LabeledEdit_PID_Min: TLabeledEdit;
    LabeledEdit_PID_Treg: TLabeledEdit;
    Edit_IniFile: TEdit;
    Button_Apply: TButton;
    Button_Save: TButton;
    LabeledEditGornNameText: TLabeledEdit;
    CheckBox_PIDUse: TCheckBox;
    procedure ButtonGornNameClick(Sender: TObject);
    procedure ButtonAddTermoClick(Sender: TObject);
    procedure ButtonDeleteTermoClick(Sender: TObject);
    procedure LabeledEditTOFFKeyPress(Sender: TObject; var Key: Char);
    procedure LabeledEditTONKeyPress(Sender: TObject; var Key: Char);
    procedure LabeledEdit_IMaxKeyPress(Sender: TObject; var Key: Char);
    procedure LabeledEdit_UMaxKeyPress(Sender: TObject; var Key: Char);
    procedure LabeledEdit_PMaxKeyPress(Sender: TObject; var Key: Char);
    procedure Button_ApplyClick(Sender: TObject);
    procedure Button_SaveClick(Sender: TObject);
    procedure GroupBox3DblClick(Sender: TObject);
  private
    { Private declarations }
    f_internal : tobject;
  public
    { Public declarations }
    m_ThID : cardinal;
    m_MainThread : cardinal;

    function ShowModal(f : tobject):integer;
    procedure SetEditTColor;
  end;

var
  SettingsFrm: TSettingsFrm;

implementation

uses uSelectChannelFrm;

{$R *.dfm}

procedure TSettingsFrm.ButtonAddTermoClick(Sender: TObject);
var
  i, j, len : Integer;
  caption_temp : String;
  temp_tag : ITag;
  adress : OleVariant;
begin
  // фильтр уже выбранных датчиков
  SetLength(SelectChannelFrm.fTags_hide, 0);
  SetLength(SelectChannelFrm.fTags_hide, ListViewTermo.Items.Count);

  for i := 0 to ListViewTermo.Items.Count - 1 do
    SelectChannelFrm.fTags_hide[i] := GetTagByName(ListViewTermo.Items[i].Caption);

  SettingsFrm.FormStyle := fsNormal;

  if SelectChannelFrm.ShowModal_Filter(self, true) = mrOk then // выбрали каналы
    begin
      for i := 0 to Length(SelectChannelFrm.Tags_selected) - 1 do
        with ListViewTermo.Items.Add do
          begin
            Caption := SelectChannelFrm.Tags_selected[i].Tag_Name; // Имя
            SubItems.Add('');                                      // Адрес
          end;

      // сортируем по имени
      len := ListViewTermo.Items.Count;
      for i := 0 to len - 1 do
      for j := 0 to len - 2 do
        if ListViewTermo.Items[j].Caption > ListViewTermo.Items[j+1].Caption then
          begin
            caption_temp := ListViewTermo.Items[j].Caption;
            ListViewTermo.Items[j].Caption := ListViewTermo.Items[j+1].Caption;
            ListViewTermo.Items[j+1].Caption := caption_temp;
          end;

      // адреса
      for i := 0 to len - 1 do
        begin
          temp_tag := GetTagByName(ListViewTermo.Items[i].Caption);
          ListViewTermo.Items[i].SubItems[0] := '';

          if temp_tag = nil then Continue;

          temp_tag.GetProperty(TAGPROP_HARDWAREADRESS, adress); // Адрес
          ListViewTermo.Items[i].SubItems[0] := adress;
        end;
    end;

  SettingsFrm.FormStyle := fsStayOnTop;
end;

procedure TSettingsFrm.ButtonDeleteTermoClick(Sender: TObject);
var
  i : Integer;
begin
  if ListViewTermo.ItemIndex <> -1 then // выбрали тег
    begin
      if MessageDlg('Вы действительно хотите удалить выбранные термодатчики?', mtWarning, mbYesNo, 0) <> mrYes then Exit;

      for i := ListViewTermo.Items.Count-1 downto 0 do
        if ListViewTermo.Items[i].Selected then
          ListViewTermo.Items.Item[i].Delete;
    end;
end;

procedure TSettingsFrm.ButtonGornNameClick(Sender: TObject);
var
  str : String;
  position : Integer;
begin
  SettingsFrm.FormStyle := fsNormal;

  if SelectChannelFrm.ShowModal_Filter(self) = mrOk then // выбрали канал
    begin
      str := SelectChannelFrm.result_Filter_Name; // получаем имя тега

      {// Удаляем в конце строки до символа '_'
      while (length(str) > 0) and
        (AnsiUpperCase(str[length(str)]) <> AnsiUpperCase('_')) do
        Delete(str, length(str), 1);

      // удаляем последний символ '_'
      if (length(str) > 0) then Delete(str, length(str), 1);}

      position := AnsiPos('_', str);
      if position = 0 then
        str := ''
      else
        Delete(str, 1, position);

      if str = '' then str := '---';

      LabeledEditGornName.Text := str; // получаем имя тега
    end;

  SettingsFrm.FormStyle := fsStayOnTop;
end;

procedure TSettingsFrm.Button_ApplyClick(Sender: TObject);
begin
  //TMainFrm(f_internal).GORN.PID_ShowConfig := CheckBox_PID_Show.Checked;
  TMainFrm(f_internal).GORN.PID_P := StrToFloat(LabeledEdit_PID_P.Text);
  TMainFrm(f_internal).GORN.PID_I := StrToFloat(LabeledEdit_PID_I.Text);
  TMainFrm(f_internal).GORN.PID_D := StrToFloat(LabeledEdit_PID_D.Text);
  TMainFrm(f_internal).GORN.PID_Min := StrToFloat(LabeledEdit_PID_Min.Text);
  TMainFrm(f_internal).GORN.PID_Treg := StrToInt(LabeledEdit_PID_Treg.Text);
end;

procedure TSettingsFrm.Button_SaveClick(Sender: TObject);
var
  PID_pIni: TIniFile;
begin
  if Edit_IniFile.Text = '' then Exit;

  with TMainFrm(f_internal) do
    begin
      GORN.PID_IniFile := Edit_IniFile.Text;

      PID_pIni := TIniFile.Create(GORN.PID_IniFile);
      //PID_pIni.WriteBool(str_PID_ini,  'PID_ShowConfig', GORN.PID_ShowConfig);
      PID_pIni.WriteFloat(str_PID_ini, 'PID_P', GORN.PID_P);
      PID_pIni.WriteFloat(str_PID_ini, 'PID_I', GORN.PID_I);
      PID_pIni.WriteFloat(str_PID_ini, 'PID_D', GORN.PID_D);
      PID_pIni.WriteFloat(str_PID_ini, 'PID_Min', GORN.PID_Min);
      PID_pIni.WriteInteger(str_PID_ini, 'PID_Treg', GORN.PID_Treg);
      PID_pIni.Free;
    end;
end;

procedure TSettingsFrm.GroupBox3DblClick(Sender: TObject);
begin
  //if Key = 'P' then
    GroupBox_PID_Config.Visible := not GroupBox_PID_Config.Visible;
end;

procedure TSettingsFrm.LabeledEditTOFFKeyPress(Sender: TObject; var Key: Char);
begin
  LabeledEditTOFF.Text := CheckKeyForFloatStr(LabeledEditTOFF.Text, Key, true);
  SetEditTColor;
end;

procedure TSettingsFrm.LabeledEditTONKeyPress(Sender: TObject; var Key: Char);
begin
  LabeledEditTON.Text := CheckKeyForFloatStr(LabeledEditTON.Text, Key, true);
  SetEditTColor;
end;

procedure TSettingsFrm.LabeledEdit_IMaxKeyPress(Sender: TObject; var Key: Char);
var
  val : Double;
begin
  LabeledEdit_IMax.Text := CheckKeyForFloatStr(LabeledEdit_IMax.Text, Key, true);
  if TryStrToFloat(LabeledEdit_IMax.Text, val) then  // проверка на число
    LabeledEdit_IMax.Color := clWindow
  else
    LabeledEdit_IMax.Color := clRed;
end;

procedure TSettingsFrm.LabeledEdit_PMaxKeyPress(Sender: TObject; var Key: Char);
var
  val : Double;
begin
  LabeledEdit_PMax.Text := CheckKeyForFloatStr(LabeledEdit_PMax.Text, Key, true);
  if TryStrToFloat(LabeledEdit_PMax.Text, val) then  // проверка на число
    LabeledEdit_PMax.Color := clWindow
  else
    LabeledEdit_PMax.Color := clRed;
end;

procedure TSettingsFrm.LabeledEdit_UMaxKeyPress(Sender: TObject; var Key: Char);
var
  val : Double;
begin
  LabeledEdit_UMax.Text := CheckKeyForFloatStr(LabeledEdit_UMax.Text, Key, true);
  if TryStrToFloat(LabeledEdit_UMax.Text, val) then  // проверка на число
    LabeledEdit_UMax.Color := clWindow
  else
    LabeledEdit_UMax.Color := clRed;
end;

function TSettingsFrm.ShowModal(f : tobject):integer;
var
  i, index : Integer;
  temp_tag : ITag;
  adress : OleVariant;
  val : Double;
begin
  GetRecorderTags;
  f_internal := f;

  LabeledEditGornName.Text     := TMainFrm(f).GORN.Name;
  LabeledEditGornNameText.Text := TMainFrm(f).GORN.NameText;

  LabeledEdit_IMax.Text := FloatToStr(TMainFrm(f).GORN.I_Max);
  LabeledEdit_UMax.Text := FloatToStr(TMainFrm(f).GORN.U_Max);
  LabeledEdit_PMax.Text := FloatToStr(TMainFrm(f).GORN.P_Max);

  // термодатчики
  ListViewTermo.Clear;

  for i := 0 to Length(TMainFrm(f).GORN.TermoTags) - 1 do // по количеству тегов
    begin
      with ListViewTermo.Items.Add do
        begin
          Caption := String(TMainFrm(f).GORN.TermoTags[i].Name); // Имя

          temp_tag := GetTagByName(TMainFrm(f).GORN.TermoTags[i].Name);

          if temp_tag = nil then
            begin
              SubItems.Add('');
              Continue;
            end;

          TMainFrm(f).GORN.TermoTags[i].Tag.GetProperty(TAGPROP_HARDWAREADRESS, adress); // Адрес
          SubItems.Add(adress);

          //SubItems.Add(IntToStr(i)); // индекс тега (ширина=0, скрыт)
        end;
    end;

  LabeledEditTON.Text   := FloatToStr(TMainFrm(f).GORN.TermoON);
  LabeledEditTOFF.Text  := FloatToStr(TMainFrm(f).GORN.TermoOFF);

  // настройки ПИД-регулятора
  CheckBox_PIDUse.Checked := TMainFrm(f).GORN.PID_Use;
  //GroupBox_PID_Config.Visible := TMainFrm(f).GORN.PID_ShowConfig;
  Edit_IniFile.Text := TMainFrm(f).GORN.PID_IniFile;
  LabeledEdit_PID_P.Text := Format('%.8f', [TMainFrm(f).GORN.PID_P]);
  LabeledEdit_PID_I.Text := Format('%.8f', [TMainFrm(f).GORN.PID_I]);
  LabeledEdit_PID_D.Text := Format('%.8f', [TMainFrm(f).GORN.PID_D]);
  LabeledEdit_PID_Min.Text := Format('%.8f', [TMainFrm(f).GORN.PID_Min]);
  LabeledEdit_PID_Treg.Text := IntToStr(TMainFrm(f).GORN.PID_Treg);

  result := inherited ShowModal;

  if result = mrYesToAll then // форму закрыли с применением
  begin
    TMainFrm(f).GORN.Name     := LabeledEditGornName.Text;
    TMainFrm(f).GORN.NameText := LabeledEditGornNameText.Text;

    // термодатчики
    SetLength(TMainFrm(f).GORN.TermoTags, 0);

    for i := 0 to ListViewTermo.Items.Count - 1 do // по всем тегам
      begin
        index := Length(TMainFrm(f).GORN.TermoTags); // увеличиваем массив
        SetLength(TMainFrm(f).GORN.TermoTags, index + 1);

        TMainFrm(f).GORN.TermoTags[index].Tag  := GetTagByName(ListViewTermo.Items[i].Caption);                                       // тег
        TMainFrm(f).GORN.TermoTags[index].Name := ListViewTermo.Items[i].Caption;               // имя
        //TMainFrm(f).GORN.Tags_selected[index].Tag_Index := StrToInt(ListView_Filter.Items[i].SubItems[1]); // индекс в массиве тегов
        //TMainFrm(f).GORN.Tags_selected[index].Tag_ITag.GetTagId(Tags_selected[index].Tag_ID);              // ID тега
      end;

    if TryStrToFloat(LabeledEdit_IMax.Text, val) then TMainFrm(f).GORN.I_Max := val;
    if TryStrToFloat(LabeledEdit_UMax.Text, val) then TMainFrm(f).GORN.U_Max := val;
    if TryStrToFloat(LabeledEdit_PMax.Text, val) then TMainFrm(f).GORN.P_Max := val;

    TMainFrm(f).GORN.PID_Use := CheckBox_PIDUse.Checked;
    TMainFrm(f).GORN.PID_IniFile := Edit_IniFile.Text;

    if TryStrToFloat(LabeledEditTON.Text,  val) then TMainFrm(f).GORN.TermoON  := val;
    if TryStrToFloat(LabeledEditTOFF.Text, val) then TMainFrm(f).GORN.TermoOFF := val;

    TMainFrm(f).ApplySettings;
  end;
end;

procedure TSettingsFrm.SetEditTColor;
var
  valON, valOFF : Double;
begin
  if TryStrToFloat(LabeledEditTON.Text, valON) then
    LabeledEditTON.Color := clWindow
  else
    LabeledEditTON.Color := clRed;

  if TryStrToFloat(LabeledEditTOFF.Text, valOFF) then
    LabeledEditTOFF.Color := clWindow
  else
    LabeledEditTOFF.Color := clRed;

  if valON >= valOFF then
    begin
      LabeledEditTON.Color := clRed;
      LabeledEditTOFF.Color := clRed;
    end;
end;

end.
