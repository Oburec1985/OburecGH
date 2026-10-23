program FrequencyResponseUiSmoke;
{$mode objfpc}{$H+}
{$codepage UTF8}
uses Interfaces, Forms, Classes, SysUtils, Controls, ExtCtrls, StdCtrls,
  ComCtrls, Graphics, Types, uRcFreqRespDlg,
  uRecorderFrequencyResponseModel, uRecorderTags, uRecorderFrequencyBands;
type
  TCloseProbe = class
    ErrorText: string;
    Opened, Commit, Locked: Boolean;
    Tags: TRecorderTagRegistry;
    procedure Check(AValue:Boolean; const AText:string);
    procedure Tick(Sender: TObject);
  end;

procedure TCloseProbe.Check(AValue:Boolean; const AText:string);
begin if not AValue then raise Exception.Create(AText); end;

procedure TCloseProbe.Tick(Sender:TObject);
var I,J:Integer; lForm:TForm; lList:TListView; lSearch:TEdit; lTree:TTreeView;
  lKind:TComboBox; lRect:TRect; lAccept:Boolean; lBitmap:TBitmap;
begin
  for I:=0 to Screen.FormCount-1 do
  begin
    lForm:=Screen.Forms[I];
    if lForm.ClassName<>'TRcFreqRespDlg' then Continue;
    TTimer(Sender).Enabled:=False;
    Opened:=True;
    try
      lList:=TListView(lForm.FindComponent('fAvailable'));
      lSearch:=TEdit(lForm.FindComponent('fSearch'));
      lTree:=TTreeView(lForm.FindComponent('fTree'));
      lKind:=TComboBox(lForm.FindComponent('fKind'));
      if Locked then begin
        lTree.Selected:=lTree.Items[0].GetFirstChild;
        lTree.OnChange(lTree,lTree.Selected);
        Check(not TComboBox(lForm.FindComponent('fFreqTag')).Enabled,'Band tacho not locked');
        Check(not TComboBox(lForm.FindComponent('fFreqMode')).Enabled,'Band frequency mode not locked');
        Check(Pos('Tacho',TLabel(lForm.FindComponent('lblFrequencyHint')).Caption)>0,'Resolved tacho hint absent: '+TLabel(lForm.FindComponent('lblFrequencyHint')).Caption);
        Check(Pos('RMS',TLabel(lForm.FindComponent('lblFrequencyHint')).Caption)>0,'Resolved RMS hint absent');
        Check(TComboBox(lForm.FindComponent('fValueTag')).Text='RMS','Resolved RMS not shown');
        lSearch.Text:='port.2';
        Check(TComboBox(lForm.FindComponent('fFreqTag')).Text='Tacho','Search lost locked frequency identity');
        Check(TComboBox(lForm.FindComponent('fValueTag')).Text='RMS','Search lost resolved value identity');
        lForm.ModalResult:=mrCancel;
        Exit;
      end;
      Check(lList.ViewStyle=vsReport,'Channel table missing');
      Check(lList.Columns.Count=2,'Channel table columns');
      Check(lList.Items[0].Caption='Датчик Alpha','Metadata leaked into name');
      Check(lList.Items[0].SubItems[0]='54000','Sampling frequency column');
      Check(lList.Parent.Left>lTree.Parent.Left+lTree.Parent.Width,'Available table is not on right');
      lList.Items[0].Selected:=True;
      lSearch.Text:='aLpH';
      Check((lList.Items.Count=1) and lList.Items[0].Selected,'Name search lost identity selection');
      lSearch.Text:='PORT.2';
      Check((lList.Items.Count=1) and (TRecorderTag(lList.Items[0].Data)=Tags.Tags[1]),'Address search');
      lSearch.Text:='ОПИСАНИЕ';
      Check((lList.Items.Count=1) and (TRecorderTag(lList.Items[0].Data)=Tags.Tags[1]),'Description UTF8 search');
      lSearch.Text:='';
      Check(lList.Items.Count=2,'Clear search');
      lKind.ItemIndex:=Ord(frkPhase);
      lKind.OnChange(lKind);
      for J:=0 to lList.Items.Count-1 do lList.Items[J].Selected:=True;
      lRect:=lTree.Items[0].DisplayRect(True);
      lTree.OnDragOver(lTree,lList,lRect.Left+2,lRect.Top+2,dsDragMove,lAccept);
      Check(lAccept,'Multiselect drag rejected');
      lTree.OnDragDrop(lTree,lList,lRect.Left+2,lRect.Top+2);
      Check(lTree.Items[0].Count=2,'Drag failed to add every selected channel');
      Check(not lKind.Enabled,'Line can override node kind');
      Check(TRecorderFrequencyResponseLine(lTree.Selected.Data).Kind=frkPhase,'Node kind not inherited');
      Check(TLabel(lForm.FindComponent('lblFrequencyHint')).Caption<>'','Automatic hint absent');
      lSearch.Text:='PORT.2';
      Check(TComboBox(lForm.FindComponent('fFreqTag')).Items.Count=2,'Shared search not applied to frequency picker');
      lSearch.Text:='';
      TEdit(lForm.FindComponent('fMinX')).Text:='1';
      TEdit(lForm.FindComponent('fMaxX')).Text:='2000';
      TEdit(lForm.FindComponent('fMinY')).Text:='0.1';
      TEdit(lForm.FindComponent('fMaxY')).Text:='180';
      TCheckBox(lForm.FindComponent('fLogX')).Checked:=True;
      TCheckBox(lForm.FindComponent('fLogY')).Checked:=True;
      Check(TEdit(lForm.FindComponent('fMinX')).Parent=TEdit(lForm.FindComponent('fMinY')).Parent,'Axes not grouped');
      lForm.SetBounds(0,0,1080,600); Application.ProcessMessages;
      Check(lList.Width>200,'Table clipped at minimum width');
      lForm.SetBounds(0,0,1160,650); Application.ProcessMessages;
      lBitmap:=lForm.GetFormImage;
      try lBitmap.SaveToFile(ExtractFilePath(ParamStr(0))+'frequency-response-dialog.bmp');
      finally lBitmap.Free; end;
      if Commit then TButton(lForm.FindComponent('btnOk')).Click
      else lForm.ModalResult:=mrCancel;
    except on E:Exception do begin ErrorText:=E.Message; lForm.ModalResult:=mrCancel; end; end;
    Exit;
  end;
end;

var lModel:TRecorderFrequencyResponseComponent; lTags:TRecorderTagRegistry;
  lProbe:TCloseProbe; lTimer:TTimer; lTag:TRecorderTag; lBand:TRecorderFrequencyBand;
begin
  try
    Application.Initialize; Application.ShowMainForm:=False;
    lModel:=TRecorderFrequencyResponseComponent.Create;
    lTags:=TRecorderTagRegistry.Create;
    lProbe:=TCloseProbe.Create;
    lTimer:=TTimer.Create(nil);
    try
      lModel.ClearLines;
      lModel.Name:='АФЧХ';
      lTag:=lTags.CreateTag('Датчик Alpha'); lTag.PollFrequencyHz:=54000; lTag.Address:='port.1';
      lTag:=lTags.CreateTag('Beta'); lTag.PollFrequencyHz:=57600; lTag.Address:='port.2'; lTag.Description:='Описание';
      lProbe.Tags:=lTags;
      lTimer.Interval:=30; lTimer.OnTimer:=@lProbe.Tick;
      lTimer.Enabled:=True;
      if ShowRcFreqRespDlg(nil,lModel,lTags) then raise Exception.Create('Cancelled draft committed');
      if not lProbe.Opened then raise Exception.Create('Editor did not open');
      if lProbe.ErrorText<>'' then raise Exception.Create(lProbe.ErrorText);
      if lModel.LineCount<>0 then raise Exception.Create('Cancelled lines retained');
      lProbe.Commit:=True; lProbe.Opened:=False; lTimer.Enabled:=True;
      if not ShowRcFreqRespDlg(nil,lModel,lTags) then raise Exception.Create(lProbe.ErrorText);
      if (lModel.LineCount<>2) or (lModel.Lines[0].SourceTagId<>lTags.Tags[0].Id) or
        (lModel.Lines[1].SourceTagId<>lTags.Tags[1].Id) then raise Exception.Create('Committed identities');
      if not lModel.LogFrequency or not lModel.Axes[0].Logarithmic then raise Exception.Create('Axis logs lost');
      if (lModel.Axes[0].MinValue<>0.1) or (lModel.MinFrequencyHz<>1) then raise Exception.Create('Axis bounds lost');
      lTag:=lTags.CreateTag('Tacho');
      lBand:=lTags.FrequencyBands.AddBand('Harmonic'); lBand.Kind:=fbkFormula;
      lBand.AddTerm(lTag.Name,1);
      lTag:=lTags.CreateTag('RMS'); lTag.SourceId:='spectrum:'+lTags.Tags[0].Name; lTag.Address:='Harmonic/rms';
      lModel.Axes[0].Kind:=frkAmplitude; lModel.Lines[0].Kind:=frkAmplitude;
      lProbe.Locked:=True; lProbe.ErrorText:=''; lTimer.Enabled:=True;
      if ShowRcFreqRespDlg(nil,lModel,lTags) then raise Exception.Create('Locked inspection committed');
      if lProbe.ErrorText<>'' then raise Exception.Create(lProbe.ErrorText);
      WriteLn('RESULT FrequencyResponseUiSmoke right-table/search/multidrag/node-kind/axes/cancel passed');
    finally lTimer.Free; lProbe.Free; lTags.Free; lModel.Free; end;
  except on E:Exception do begin WriteLn('RESULT FrequencyResponseUiSmoke failed: ',E.Message); Halt(1); end; end;
end.
