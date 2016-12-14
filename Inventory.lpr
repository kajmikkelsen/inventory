program Inventory;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, Main,  upreferences,
  { you can add units after this }
  mylib, UEdit, UGroups, ugroupedit, uwrite_port, uabout;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TFPref, FPref);
  Application.CreateForm(TEditForm, EditForm);
  Application.CreateForm(TFGroups, FGroups);
  Application.CreateForm(TFGroupEdit, FGroupEdit);
  Application.CreateForm(TFWrite_Port, FWrite_Port);
  Application.CreateForm(TFAbout, FAbout);
  Application.Run;
end.

