// Copyright 2017, Kaj Mikkelsen
// This software is distributed under the GPL 3 license
// The full text of the license can be found in the aboutbox
// as well as in the file "Copying"

program Inventory;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  Main,
  upreferences,
  { you can add units after this }
  mylib,
  UEdit,
  UGroups,
  ugroupedit,
  uwrite_port,
  uabout,
  UMyShowMessage, usplash;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.Title:= 'Inventory';
   FSplash := TFsplash.create(application);
   FSplash.show;
   FSplash.Update;
   application.ProcessMessages;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TFPref, FPref);
  Application.CreateForm(TEditForm, EditForm);
  Application.CreateForm(TFGroups, FGroups);
  Application.CreateForm(TFGroupEdit, FGroupEdit);
  Application.CreateForm(TFWrite_Port, FWrite_Port);
  Application.CreateForm(TFAbout, FAbout);
  Application.CreateForm(TFMyShowMessage, FMyShowMessage);
  FSplash.close;
  FSplash.Release;

  Application.Run;
end.
