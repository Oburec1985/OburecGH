unit uCustomEditControlFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, inifiles, uControlObj, ubtnlistview;

type
  TCustomControlEditFrame = class(TFrame)
  private
    m:cControlMng;
  public
    procedure EndMS;virtual;abstract;
    function GetDsc:string;virtual;abstract;
    procedure doUpdateChannelList;virtual;abstract;
    procedure Save(f:tinifile; section:string);virtual;abstract;
    procedure Load(f:tinifile; section:string);virtual;abstract;
    function ControlType:string;virtual;abstract;
    procedure editcontrol(c:cControlObj);virtual;abstract;
    procedure ShowControlProps(con:ccontrolobj; endMS:boolean);virtual;abstract;
    procedure linkChannelsLV(drover:TDragOverEvent; drdrop:TDragDropEvent);virtual;abstract;
  published
  end;

implementation

{$R *.dfm}

end.
