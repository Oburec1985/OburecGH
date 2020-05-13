unit uBaseModificator;

interface
  type
  cBaseModificator = class
  public
    modtype:byte;
    owner:tobject;
    name:string;
  public
    constructor create(obj:tobject);virtual;abstract;
    destructor destroy;virtual;
  public
    procedure apply;virtual;abstract;
  end;

implementation

destructor cBaseModificator.destroy;
begin
  inherited;
end;

end.
