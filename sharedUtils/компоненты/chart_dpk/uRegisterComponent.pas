unit uRegisterComponent;

interface
uses
  Windows, Classes, uChart;

procedure Register;

implementation

procedure Register;
begin
     RegisterComponents('Samples', [cChart]);
end;



end.
