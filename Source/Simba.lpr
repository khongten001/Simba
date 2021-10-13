{
  Author: Raymond van Venetië and Merlijn Wajer
  Project: Simba (https://github.com/MerlijnWajer/Simba)
  License: GNU General Public License (https://www.gnu.org/licenses/gpl-3.0)
}
program Simba;

{$i simba.inc}
{$R Simba.res}

uses
  simba.init,
  classes, sysutils, interfaces, forms, lazloggerbase,
  simba.settings, simba.main, simba.aboutform, simba.debugimageform,
  simba.bitmapconv, simba.functionlistform, simba.scripttabsform,
  simba.outputform, simba.colorpickerhistoryform, simba.filebrowserform,
  simba.notesform, simba.package_form, simba.settingsform, simba.associate,
  simba.script, simba.script_dump, simba.openexampleform, simba.httpclient;

type
  TApplicationHelper = class helper for TApplication
    procedure HandleException(Sender: TObject; E: Exception);
    procedure HandleAnalytics(Data: PtrInt);
    procedure SendAnalytics;
  end;

procedure TApplicationHelper.HandleException(Sender: TObject; E: Exception);
begin
  { no graphical error message at this point }
end;

procedure TApplicationHelper.HandleAnalytics(Data: PtrInt);
begin
  TThread.ExecuteInThread(@SendAnalytics);
end;

procedure TApplicationHelper.SendAnalytics;
begin
  with TSimbaHTTPClient.Create() do
  try
    // Simple HTTP request - nothing extra is sent.
    // Only used for logging very basic (ide) launch metrics.
    Get(SIMBA_ANALYTICS_URL);
  finally
    Free();
  end;
end;

begin
  {$IF DECLARED(SetHeapTraceOutput)}
  SetHeapTraceOutput('memory-leaks.trc');
  {$ENDIF}

  Application.OnException := @Application.HandleException;
  Application.Title := 'Simba';
  Application.Scaled := True;
  Application.Initialize();

  if Application.HasOption('dumpcompiler') then
  begin
    with DumpCompiler() do
      SaveToFile(Application.Params[Application.ParamCount]);

    Halt();
  end;

  if Application.HasOption('dumpplugin') then
  begin
    with DumpPlugin(Application.GetOptionValue('dumpplugin')) do
      SaveToFile(Application.Params[Application.ParamCount]);

    Halt();
  end;

  if Application.HasOption('associate') then
  begin
    Associate();

    Halt();
  end;

  if not Application.HasOption('open') and Application.HasOption('run') or Application.HasOption('compile') then
  begin
    if not FileExists(Application.Params[Application.ParamCount]) then
    begin
      DebugLn('Script "' + Application.Params[Application.ParamCount] + '" does not exist.');

      Halt();
    end;

    SimbaScript := TSimbaScript.Create();

    SimbaScript.ScriptFile               := Application.Params[Application.ParamCount];
    SimbaScript.ScriptName               := Application.GetOptionValue('scriptname');
    SimbaScript.SimbaCommunicationServer := Application.GetOptionValue('simbacommunication');
    SimbaScript.Target                   := Application.GetOptionValue('target');
    SimbaScript.Debugging                := Application.HasOption('debugging');
    SimbaScript.CompileOnly              := Application.HasOption('compile');
    SimbaScript.Silent                   := Application.HasOption('silent');

    SimbaScript.Start();
  end else
  begin
    Application.CreateForm(TSimbaForm, SimbaForm);
    Application.CreateForm(TSimbaFunctionListForm, SimbaFunctionListForm);
    Application.CreateForm(TSimbaDebugImageForm, SimbaDebugImageForm);
    Application.CreateForm(TSimbaNotesForm, SimbaNotesForm);
    Application.CreateForm(TSimbaScriptTabsForm, SimbaScriptTabsForm);
    Application.CreateForm(TSimbaOutputForm, SimbaOutputForm);
    Application.CreateForm(TSimbaFileBrowserForm, SimbaFileBrowserForm);
    Application.CreateForm(TSimbaAboutForm, SimbaAboutForm);
    Application.CreateForm(TSimbaSettingsForm, SimbaSettingsForm);
    Application.CreateForm(TSimbaBitmapConversionForm, SimbaBitmapConversionForm);
    Application.CreateForm(TSimbaPackageForm, SimbaPackageForm);
    Application.CreateForm(TSimbaOpenExampleForm, SimbaOpenExampleForm);
    Application.CreateForm(TSimbaColorPickerHistoryForm, SimbaColorPickerHistoryForm);

    Application.QueueAsyncCall(@Application.HandleAnalytics, 0);
  end;

  Application.Run();
end.
