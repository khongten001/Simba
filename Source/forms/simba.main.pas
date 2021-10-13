{
  Author: Raymond van Venetië and Merlijn Wajer
  Project: Simba (https://github.com/MerlijnWajer/Simba)
  License: GNU General Public License (https://www.gnu.org/licenses/gpl-3.0)
}
unit simba.main;

{$i simba.inc}

interface

uses
  classes, sysutils, fileutil, anchordockpanel, forms, controls, graphics, dialogs,
  stdctrls, menus, comctrls, extctrls, buttons, imglist, castaliapaslextypes,
  simba.settings, simba.oswindow;

const
  IMAGE_COMPILE             = 0;
  IMAGE_PACKAGE             = 1;
  IMAGE_COPY                = 2;
  IMAGE_CUT                 = 3;
  IMAGE_OPEN                = 4;
  IMAGE_PASTE               = 5;
  IMAGE_SAVE                = 6;
  IMAGE_TRASH               = 7;
  IMAGE_CLOSE               = 8;
  IMAGE_CLOSE_ALL           = 9;
  IMAGE_POWER               = 10;
  IMAGE_NEW_FILE            = 11;
  IMAGE_PAUSE               = 12;
  IMAGE_REDO                = 13;
  IMAGE_PLAY                = 14;
  IMAGE_SAVE_ALL            = 15;
  IMAGE_STOP                = 16;
  IMAGE_UNDO                = 17;
  IMAGE_SEARCH              = 18;
  IMAGE_COLOR_PICKER        = 19;
  IMAGE_SELECT              = 20;
  IMAGE_GEAR                = 21;
  IMAGE_OPEN_RECENT         = 22;
  IMAGE_PACKAGE_NOTIFCATION = 23;
  IMAGE_WRITE_BUG           = 24;
  IMAGE_MINUS               = 25;
  IMAGE_PLUS                = 26;
  IMAGE_DIRECTORY           = 27;
  IMAGE_SIMBA               = 28;
  IMAGE_BOOK                = 29;
  IMAGE_FILE                = 30;
  IMAGE_TYPE                = 31;
  IMAGE_FUNCTION            = 32;
  IMAGE_PROCEDURE           = 33;
  IMAGE_GITHUB              = 34;
  IMAGE_CONSTANT            = 35;
  IMAGE_VARIABLE            = 36;

type
  TSimbaForm = class(TForm)
    DockPanel: TAnchorDockPanel;
    Images: TImageList;
    MainMenu: TMainMenu;
    MenuEdit: TMenuItem;
    MenuFile: TMenuItem;
    MenuHelp: TMenuItem;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItemAbout: TMenuItem;
    MenuItemACA: TMenuItem;
    MenuItemAssociateScripts: TMenuItem;
    MenuItemBitmapConv: TMenuItem;
    MenuItemCloseTab: TMenuItem;
    MenuItemCloseTabs: TMenuItem;
    MenuItemColourHistory: TMenuItem;
    MenuItemCompile: TMenuItem;
    MenuItemConsole: TMenuItem;
    MenuItemCopy: TMenuItem;
    MenuItemCut: TMenuItem;
    MenuItemDebugger: TMenuItem;
    MenuItemDebugImage: TMenuItem;
    MenuItemDivider10: TMenuItem;
    MenuItemDivider11: TMenuItem;
    MenuItemDivider14: TMenuItem;
    MenuItemDivider2: TMenuItem;
    MenuItemDivider3: TMenuItem;
    MenuItemDivider4: TMenuItem;
    MenuItemDivider5: TMenuItem;
    MenuItemDivider6: TMenuItem;
    MenuItemDTMEditor: TMenuItem;
    MenuItemEditor: TMenuItem;
    MenuItemExample: TMenuItem;
    MenuItemFileBrowser: TMenuItem;
    MenuItemFind: TMenuItem;
    MenuItemFindNext: TMenuItem;
    MenuItemFindPrev: TMenuItem;
    MenuItemFormatScript: TMenuItem;
    MenuItemFunctionList: TMenuItem;
    MenuItemGoto: TMenuItem;
    MenuItemLockLayout: TMenuItem;
    MenuItemMainExit: TMenuItem;
    MenuItemNew: TMenuItem;
    MenuItemNotes: TMenuItem;
    MenuItemOpen: TMenuItem;
    MenuItemOpenRecent: TMenuItem;
    MenuItemOutput: TMenuItem;
    MenuItemPackages: TMenuItem;
    MenuItemPaste: TMenuItem;
    MenuItemPause: TMenuItem;
    MenuItemRedo: TMenuItem;
    MenuItemReplace: TMenuItem;
    MenuItemReportBug: TMenuItem;
    MenuItemResetLayout: TMenuItem;
    MenuItemRun: TMenuItem;
    MenuItemRunWithDebugging: TMenuItem;
    MenuItemSave: TMenuItem;
    MenuItemSaveAll: TMenuItem;
    MenuItemSaveAs: TMenuItem;
    MenuItemSaveDefault: TMenuItem;
    MenuItemScript: TMenuItem;
    MenuItemSelectAll: TMenuItem;
    MenuItemSettings: TMenuItem;
    MenuItemStop: TMenuItem;
    MenuItemTrayIcon: TMenuItem;
    MenuItemUndo: TMenuItem;
    MenuTools: TMenuItem;
    MenuView: TMenuItem;
    StatusBar: TPanel;
    StatusPanelCaret: TPanel;
    StatusPanelCursor: TPanel;
    StatusPanelFileName: TPanel;
    StatusPanelState: TPanel;
    StopButtonStop: TToolButton;
    Timer: TTimer;
    ToolBar: TToolBar;
    ToolbarButtonClearOutput: TToolButton;
    ToolbarButtonColorPicker: TToolButton;
    ToolbarButtonCompile: TToolButton;
    ToolbarButtonNew: TToolButton;
    ToolbarButtonOpen: TToolButton;
    ToolbarButtonPackages: TToolButton;
    ToolbarButtonPause: TToolButton;
    ToolbarButtonRun: TToolButton;
    ToolbarButtonSave: TToolButton;
    ToolbarButtonSaveAll: TToolButton;
    ToolbarButtonTargetSelector: TToolButton;
    ToolbarDivider1: TToolButton;
    ToolbarDivider2: TToolButton;
    ToolbarDivider3: TToolButton;
    ToolbarDivider4: TToolButton;
    ToolbarDivider5: TToolButton;
    TrayIcon: TTrayIcon;
    TrayPopup: TPopupMenu;
    TrayPopupExit: TMenuItem;

    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuClearOutputClick(Sender: TObject);
    procedure MenuCloseAllTabsClick(Sender: TObject);
    procedure MenuCloseTabClick(Sender: TObject);
    procedure MenuCopyClick(Sender: TObject);
    procedure MenuCutClick(Sender: TObject);
    procedure MenuEditClick(Sender: TObject);
    procedure MenuExitClick(Sender: TObject);
    procedure MenuFileClick(Sender: TObject);
    procedure MenuFindClick(Sender: TObject);
    procedure MenuGotoClick(Sender: TObject);
    procedure MenuItemAboutClick(Sender: TObject);
    procedure MenuItemACAClick(Sender: TObject);
    procedure MenuItemAssociateScriptsClick(Sender: TObject);
    procedure MenuItemBitmapConvClick(Sender: TObject);
    procedure MenuItemCloseTabsClick(Sender: TObject);
    procedure MenuItemConsoleClick(Sender: TObject);
    procedure MenuItemDebuggerClick(Sender: TObject);
    procedure MenuItemDTMEditorClick(Sender: TObject);
    procedure MenuItemFindNextClick(Sender: TObject);
    procedure MenuItemFindPrevClick(Sender: TObject);
    procedure MenuItemFormatScriptClick(Sender: TObject);
    procedure MenuItemLockLayoutClick(Sender: TObject);
    procedure MenuItemReportBugClick(Sender: TObject);
    procedure MenuItemResetLayoutClick(Sender: TObject);
    procedure MenuItemScriptStateClick(Sender: TObject);
    procedure MenuItemSettingsClick(Sender: TObject);
    procedure MenuItemTrayIconClick(Sender: TObject);
    procedure MenuNewClick(Sender: TObject);
    procedure MenuNewTemplateClick(Sender: TObject);
    procedure MenuOpenClick(Sender: TObject);
    procedure MenuPasteClick(Sender: TObject);
    procedure MenuRedoClick(Sender: TObject);
    procedure MenuReplaceClick(Sender: TObject);
    procedure MenuSaveAsClick(Sender: TObject);
    procedure MenuSaveAsDefaultClick(Sender: TObject);
    procedure MenuSaveClick(Sender: TObject);
    procedure MenuSelectAllClick(Sender: TObject);
    procedure MenuUndoClick(Sender: TObject);
    procedure MenuViewClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure ToolbarButtonColorPickerClick(Sender: TObject);
    procedure ToolbarButtonPackagesClick(Sender: TObject);
    procedure ToolbarButtonSaveAllClick(Sender: TObject);
    procedure ToolbarButtonSelectTargetClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure TrayIconClick(Sender: TObject);
    procedure TrayPopupExitClick(Sender: TObject);
  protected
    FWindowSelection: TOSWindow;
    FProcessSelection: UInt32;
    FDockingReset: Boolean;
    FRecentFiles: TStringList;

    procedure ShowColorPickerHistoryASync(Data: PtrInt);

    procedure FontChanged(Sender: TObject); override;

    procedure SizeComponents;

    procedure SimbaSettingChanged(Setting: TSimbaSetting);

    procedure HandleRecentFileClick(Sender: TObject);
    procedure HandlePrintDTM(DTM: String);
    procedure HandleException(Sender: TObject; E: Exception);
    procedure HandleFormCreated(Sender: TObject; Form: TCustomForm);
    procedure HandleEditorChanged(Sender: TObject);
    procedure HandleEditorLoaded(Sender: TObject);
    procedure HandleEditorCaretChange(Sender: TObject);
    procedure HandleEditorSearch(Sender: TObject);

    procedure SetToolbarSize(Value: Integer);
    procedure SetCustomFontSize(Value: Integer);
    procedure SetConsoleVisible(Value: Boolean);
    procedure SetLayoutLocked(Value: Boolean);
    procedure SetTrayIconVisible(Value: Boolean);
    procedure SetMacOSKeystokes(Value: Boolean);
  public
    property WindowSelection: TOSWindow read FWindowSelection;
    property ProcessSelection: UInt32 read FProcessSelection;

    procedure SetupScriptTabs(Sender: TObject);
    procedure SetupDocking(Sender: TObject);
    procedure SetupCompleted(Sender: TObject);

    procedure CodeTools_Setup;
    procedure CodeTools_OnMessage(Sender: TObject; const Typ: TMessageEventType; const Message: String; X, Y: Integer);
    procedure CodeTools_OnLoadLibrary(Sender: TObject; FileName: String; var Contents: String);

    function CodeTools_OnFindInclude(Sender: TObject; var FileName: String): Boolean;
    function CodeTools_OnFindLibrary(Sender: TObject; var FileName: String): Boolean;
  end;

var
  SimbaForm: TSimbaForm;

implementation

{$R *.lfm}

uses
  types, lclintf, lazloggerbase, lazfileutils, anchordocking,
  simba.openssl, simba.files, simba.mufasatypes, simba.process,
  simba.openexampleform, simba.colorpickerhistoryform, simba.codeparser,
  simba.codeinsight, simba.associate, simba.scripttab, simba.debugimageform,
  simba.bitmapconv, simba.aca, simba.windowselector, simba.dtmeditor,
  simba.package_form, simba.aboutform, simba.functionlistform,
  simba.scripttabsform, simba.outputform, simba.filebrowserform,
  simba.notesform, simba.settingsform, simba.colorpicker,
  simba.ci_includecache, simba.script_communication, simba.scriptformatter,
  simba.editor, simba.dockinghelpers, simba.misc;

procedure TSimbaForm.HandleException(Sender: TObject; E: Exception);

  procedure Dump(Addr: Pointer; List: TStringList);
  begin
    // preventing another exception, while dumping stack trace
    try
      List.Add(BackTraceStrFunc(Addr));
    except
      List.Add(SysBackTraceStr(Addr));
    end;
  end;

  procedure DumpStack(List: TStringList);
  var
    FrameCount, FrameIndex: Integer;
    Frames: PPointer;
  begin
    Dump(ExceptAddr, List);

    FrameCount := ExceptFrameCount;
    Frames := ExceptFrames;
    for FrameIndex := 0 to FrameCount - 1 do
      Dump(Frames[FrameIndex], List);
  end;

var
  Log: TStringList;
  FileName, Message: String;
begin
  try
    Log := TStringList.Create();
    Log.Add('Simba %d encountered an unhandled exception.', [SIMBA_VERSION]);
    Log.Add('Simba commit: %s', [SIMBA_COMMIT]);
    Log.Add('');
    Log.Add('Exception: %s', [E.Message]);
    Log.Add('Exception Class: %s', [E.ClassName]);
    Log.Add('');

    DumpStack(Log);

    FileName := GetDataPath() + FormatDateTime('dd-mm_hh-mm-ss', Now()) + '.crash';

    Log.SaveToFile(FileName);
    Log.Free();

    Message := '%s'                                                     + LineEnding +
               ''                                                       + LineEnding +
               'Press OK to save your scripts and close. (Recommended)' + LineEnding +
               'Press Cancel to ignore and risk data corruption.'       + LineEnding +
               ''                                                       + LineEnding +
               'A crash log has been saved in the data directory.';

    if MessageDlg(Format(Message, [E.Message, ExtractRelativePath(GetSimbaPath(), FileName)]), mtError, mbOKCancel, 0) = mrOk then
    begin
      SimbaScriptTabsForm.CloseAllTabs();

      Halt(1);
    end;
  except
    // circular exception ...
  end;
end;

procedure TSimbaForm.SetToolbarSize(Value: Integer);
begin
  ToolBar.ImagesWidth := Value;

  ToolBar.ButtonWidth  := Value + 8;
  ToolBar.ButtonHeight := Value + 8;
end;

procedure TSimbaForm.SetCustomFontSize(Value: Integer);
var
  I: Integer;
begin
  for I := 0 to Screen.CustomFormCount - 1 do
    Screen.CustomForms[I].Font.Size := Value;
end;

procedure TSimbaForm.SetConsoleVisible(Value: Boolean);
begin
  MenuItemConsole.Checked := Value;

  SetTerminalVisible(Value);
end;

procedure TSimbaForm.SetLayoutLocked(Value: Boolean);
begin
  MenuItemLockLayout.Checked := Value;

  DockMaster.ShowHeader := not Value;
  DockMaster.AllowDragging := not Value;
end;

procedure TSimbaForm.SetTrayIconVisible(Value: Boolean);
begin
  MenuItemTrayIcon.Checked := Value;

  TrayIcon.Visible := Value;
end;

procedure TSimbaForm.SetMacOSKeystokes(Value: Boolean);
var
  Find: TShiftStateEnum;
  Replace: TShiftStateEnum;

  procedure SetMacOSKeystroke(const MenuItem: TMenuItem);
  var
    I: Integer;
    Key: Word;
    Shift: TShiftState;
  begin
    if (MenuItem.ShortCut > 0) then
    begin
      ShortCutToKey(MenuItem.ShortCut, Key, Shift);
      if (Find in Shift) then
        MenuItem.ShortCut := ShortCut(Key, Shift - [Find] + [Replace]);
    end;

    for I := 0 to MenuItem.Count - 1 do
      SetMacOSKeystroke(MenuItem.Items[I]);
  end;

begin
  if Value then Find := ssCtrl else Find := ssMeta;
  if Value then Replace := ssMeta else Replace := ssCtrl;

  SetMacOSKeystroke(MainMenu.Items);
end;

procedure TSimbaForm.CodeTools_OnMessage(Sender: TObject; const Typ: TMessageEventType; const Message: String; X, Y: Integer);
var
  Parser: TCodeParser absolute Sender;
begin
  if (Parser.Lexer.TokenPos + Parser.Lexer.TokenLen < Parser.Lexer.CaretPos) then
  begin
    SimbaOutputForm.Add('Simba''s code parser encountered an error. This could break code tools:');

    if (Parser.Lexer.FileName <> '') then
      SimbaOutputForm.Add(Format('"%s" at line %d, column %d in file "%s"', [Message, Y + 1, X, Parser.Lexer.FileName]))
    else
      SimbaOutputForm.Add(Format('"%s" at line %d, column %d', [Message, Y + 1, X]));
  end;
end;

function TSimbaForm.CodeTools_OnFindInclude(Sender: TObject; var FileName: String): Boolean;
begin
  Result := FindFile(FileName, '', [ExtractFileDir(TCodeParser(Sender).Lexer.FileName), GetIncludePath(), GetSimbaPath()]);
end;

function TSimbaForm.CodeTools_OnFindLibrary(Sender: TObject; var FileName: String): Boolean;
begin
  Result := FindPlugin(FileName, [ExtractFileDir(TCodeParser(Sender).Lexer.FileName), GetPluginPath(), GetSimbaPath()]);
end;

procedure TSimbaForm.HandleFormCreated(Sender: TObject; Form: TCustomForm);
begin
  if (SimbaSettings.GUI.CustomFontSize.Value > 0) then
    Form.Font.Size := SimbaSettings.GUI.CustomFontSize.Value;
end;

procedure TSimbaForm.CodeTools_OnLoadLibrary(Sender: TObject; FileName: String; var Contents: String);
var
  CacheFileName: String;
  List: TStringList;
begin
  Contents := '';

  CacheFileName := GetDumpPath() + HashFile(FileName);

  try
    List := nil;

    if FileExists(CacheFileName) then
    begin
      List := TStringList.Create();
      List.LoadFromFile(CacheFileName);
    end else
    begin
      List := SimbaProcess.RunDump(['--dumpplugin=' + FileName]);
      List.SaveToFile(CacheFileName);
    end;

    Contents := List.Text;
  except
    on E: Exception do
      DebugLn(E.Message);
  end;

  if (List <> nil) then
    List.Free();
end;

procedure TSimbaForm.CodeTools_Setup;
var
  List: TStringList;
  FileName: String;
  I: Integer;
  Parser: TCodeInsight_Include;
begin
  List := nil;

  FileName := GetDumpPath() + HashFile(Application.ExeName);

  try
    if FileExists(FileName) then
    begin
      List := TStringList.Create();
      List.LineBreak := #0;
      List.LoadFromFile(FileName);
    end else
    begin
      List := SimbaProcess.RunDump(['--dumpcompiler']);
      List.SaveToFile(FileName);
    end;

    for I := 0 to List.Count - 1 do
    begin
      Parser := TCodeInsight_Include.Create();
      Parser.OnMessage := @Self.CodeTools_OnMessage;
      Parser.Run(List.ValueFromIndex[I], List.Names[I]);

      if (List.Names[I] <> 'Classes') then
        TCodeInsight.AddFunctionListSection(Parser);

      TCodeInsight.AddBaseInclude(Parser);
    end;
  except
    on E: Exception do
      DebugLn(E.Message);
  end;

  if (List <> nil) then
    List.Free();
end;

procedure TSimbaForm.HandleRecentFileClick(Sender: TObject);
begin
  SimbaScriptTabsForm.Open(TMenuItem(Sender).Hint, True);
end;

procedure TSimbaForm.MenuItemAssociateScriptsClick(Sender: TObject);
const
  Message = 'Would you like to associate scripts with this Simba?' + LineEnding +
            'This means when opening a script, the script will be opened using this Simba executable.';
begin
  {$IFDEF WINDOWS}
  if MessageDlg(Message, mtConfirmation, mbYesNo, 0) = mrYes then
    Associate();
  {$ENDIF}
end;

procedure TSimbaForm.MenuNewTemplateClick(Sender: TObject);
begin
  SimbaOpenExampleForm.ShowModal();
end;

procedure TSimbaForm.MenuViewClick(Sender: TObject);
begin
  MenuItemDebugger.Enabled := SimbaScriptTabsForm.CurrentTab.DebuggingForm <> nil;
end;

procedure TSimbaForm.MenuItemFormatScriptClick(Sender: TObject);
var
  Script: String;
begin
  try
    SimbaScriptTabsForm.CurrentEditor.BeginUndoBlock();

    try
      if SimbaScriptTabsForm.CurrentEditor.SelAvail then
        SimbaScriptTabsForm.CurrentEditor.SelText := FormatScript(SimbaScriptTabsForm.CurrentEditor.SelText)
      else
      begin
        Script := SimbaScriptTabsForm.CurrentEditor.Text;

        SimbaScriptTabsForm.CurrentEditor.ClearAll();
        SimbaScriptTabsForm.CurrentEditor.InsertTextAtCaret(FormatScript(Script));
      end;
    finally
      SimbaScriptTabsForm.CurrentEditor.EndUndoBlock();
    end;
  except
    on E: Exception do
      ShowMessage('Exception while formatting script: ' + E.Message);
  end;
end;

procedure TSimbaForm.MenuItemAboutClick(Sender: TObject);
begin
  SimbaAboutForm.ShowModal();
end;

procedure TSimbaForm.TrayPopupExitClick(Sender: TObject);
begin
  Close();
end;

procedure TSimbaForm.FormCreate(Sender: TObject);
begin
  Application.OnException := @SimbaForm.HandleException;
  Screen.AddHandlerFormAdded(@SimbaForm.HandleFormCreated, True);

  FRecentFiles := TStringList.Create();
  FRecentFiles.Text := SimbaSettings.GUI.RecentFiles.Value;

  CreateBaseDirectories();
  if SimbaSettings.Environment.OpenSSLOnLaunch.Value then
    InitializeOpenSSL();

  CodeTools_Setup();

  AddHandlerFirstShow(@SetupScriptTabs, True);
  AddHandlerFirstShow(@SetupDocking, True);
  AddHandlerFirstShow(@SetupCompleted, True);

  SimbaSettings.RegisterChangeHandler(@SimbaSettingChanged);

  SimbaSettingChanged(SimbaSettings.GUI.ToolbarSize);
  SimbaSettingChanged(SimbaSettings.GUI.CustomFontSize);
  SimbaSettingChanged(SimbaSettings.GUI.LockLayout);
  SimbaSettingChanged(SimbaSettings.GUI.TrayIconVisible);
  SimbaSettingChanged(SimbaSettings.GUI.ConsoleVisible);

  if SimbaSettings.GUI.MacOSKeystrokes.Value then
    SimbaSettingChanged(SimbaSettings.GUI.MacOSKeystrokes);
end;

procedure TSimbaForm.FormDestroy(Sender: TObject);
begin
  if (SimbaSettings <> nil) then
    SimbaSettings.UnRegisterChangeHandler(@SimbaSettingChanged);

  if (FRecentFiles <> nil) then
  begin
    SimbaSettings.GUI.RecentFiles.Value := FRecentFiles.Text;

    FreeAndNil(FRecentFiles);
  end;
end;

procedure TSimbaForm.MenuItemDebuggerClick(Sender: TObject);
begin
  if (SimbaScriptTabsForm.CurrentTab.DebuggingForm <> nil) then
    SimbaScriptTabsForm.CurrentTab.DebuggingForm.ShowOnTop();
end;

procedure TSimbaForm.MenuItemACAClick(Sender: TObject);
begin
  TSimbaACAForm.Create(WindowSelection).ShowOnTop();
end;

procedure TSimbaForm.MenuItemScriptStateClick(Sender: TObject);
var
  CurrentTab: TSimbaScriptTab;
begin
  CurrentTab := SimbaScriptTabsForm.CurrentTab;

  if (CurrentTab <> nil) then
  try
    with CurrentTab do
    begin
      if (Sender = MenuItemCompile) or (Sender = ToolbarButtonCompile) then
        Compile()
      else
      if (Sender = MenuItemRun) or (Sender = ToolbarButtonRun) then
        Run(FWindowSelection)
      else
      if (Sender = MenuItemRunWithDebugging) then
        RunWithDebugging(FWindowSelection)
      else
      if (Sender = MenuItemPause) or (Sender = ToolbarButtonPause) then
        Pause()
      else
      if (Sender = MenuItemStop) or (Sender = StopButtonStop) then
        Stop()
    end;
  except
    on E: Exception do
      MessageDlg('Exception while changing script state: ' + E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TSimbaForm.ShowColorPickerHistoryASync(Data: PtrInt);
begin
  MenuItemColourHistory.Checked := True;
  MenuItemColourHistory.OnClick(MenuItemColourHistory);
end;

procedure TSimbaForm.FontChanged(Sender: TObject);
begin
  inherited FontChanged(Sender);

  SizeComponents();
end;

procedure TSimbaForm.SizeComponents;
var
  Size: TSize;
begin
  if (ControlCount = 0) then
    Exit;

  with TBitmap.Create() do
  try
    Canvas.Font := Self.Font;
    Size := Canvas.TextExtent('TaylorSwift');
  finally
    Free();
  end;

  StatusBar.Height := Round(Size.Height * 1.4);

  StatusPanelCursor.Width := Round(Size.Width * 1.8);
  StatusPanelState.Width  := Round(Size.Width * 1.6);
  StatusPanelCaret.Width  := Round(Size.Width * 2);
end;

procedure TSimbaForm.SimbaSettingChanged(Setting: TSimbaSetting);
begin
  if (Setting = SimbaSettings.GUI.ToolbarSize) then
    SetToolbarSize(Setting.Value);
  if (Setting = SimbaSettings.GUI.CustomFontSize) then
    SetCustomFontSize(Setting.Value);
  if (Setting = SimbaSettings.GUI.ConsoleVisible) then
    SetConsoleVisible(Setting.Value);
  if (Setting = SimbaSettings.GUI.LockLayout) then
    SetLayoutLocked(Setting.Value);
  if (Setting = SimbaSettings.GUI.TrayIconVisible) then
    SetTrayIconVisible(Setting.Value);
  if (Setting = SimbaSettings.GUI.MacOSKeystrokes) then
    SetMacOSKeystokes(Setting.Value);
end;

procedure TSimbaForm.MenuCloseTabClick(Sender: TObject);
begin
  SimbaScriptTabsForm.CloseTab(SimbaScriptTabsForm.CurrentTab);
end;

procedure TSimbaForm.MenuCopyClick(Sender: TObject);
begin
  if (SimbaScriptTabsForm.CurrentEditor <> nil) then
    SimbaScriptTabsForm.CurrentEditor.CopyToClipboard();
end;

procedure TSimbaForm.MenuCutClick(Sender: TObject);
begin
  if (SimbaScriptTabsForm.CurrentEditor <> nil) then
    SimbaScriptTabsForm.CurrentEditor.CutToClipboard();
end;

procedure TSimbaForm.MenuExitClick(Sender: TObject);
begin
  Self.Close();
end;

procedure TSimbaForm.MenuGotoClick(Sender: TObject);
var
  Value: String;
begin
  if SimbaScriptTabsForm.CurrentEditor <> nil then
  begin
    Value := '';
    if InputQuery('Goto line', 'Goto line:', Value) and (StrToIntDef(Value, -1) > -1) then
      SimbaScriptTabsForm.CurrentEditor.TopLine := StrToInt(Value) - (SimbaScriptTabsForm.CurrentEditor.LinesInWindow div 2);
  end;
end;

procedure TSimbaForm.MenuClearOutputClick(Sender: TObject);
begin
  SimbaOutputForm.Clear();
end;

procedure TSimbaForm.MenuFileClick(Sender: TObject);
var
  I: Integer;
  Item: TMenuItem;
begin
  MenuItemSaveAll.Enabled := SimbaScriptTabsForm.TabCount > 1;
  MenuItemOpenRecent.Clear();

  I := 0;
  while (I < FRecentFiles.Count) do
  begin
    if (not FileExists(FRecentFiles[I])) then
    begin
      FRecentFiles.Delete(I);

      Continue;
    end;

    Item := TMenuItem.Create(MenuItemOpenRecent);
    Item.Caption := ShortDisplayFilename(FRecentFiles[I]);
    Item.OnClick := @HandleRecentFileClick;
    Item.Hint := FRecentFiles[I];

    MenuItemOpenRecent.Add(Item);

    Inc(I);
  end;
end;

procedure TSimbaForm.MenuSaveAsDefaultClick(Sender: TObject);
begin
  if MessageDlg('Are you sure you want to overwrite the default script?', mtConfirmation, [mbYes, mbCancel], 0) = mrYes then
    SimbaSettings.Editor.DefaultScript.Value := SimbaScriptTabsForm.CurrentEditor.Text;
end;

procedure TSimbaForm.MenuCloseAllTabsClick(Sender: TObject);
begin
  SimbaScriptTabsForm.CloseAllTabs();
end;

procedure TSimbaForm.MenuNewClick(Sender: TObject);
begin
  SimbaScriptTabsForm.AddTab();
end;

procedure TSimbaForm.HandlePrintDTM(DTM: String);
begin
  SimbaOutputForm.Add('DTM := DTMFromString(' + #39 + DTM + #39 + ');');
end;

procedure TSimbaForm.MenuItemDTMEditorClick(Sender: TObject);
begin
  with TSimbaDTMEditorForm.Create(WindowSelection) do
  begin
    OnPrintDTM := @HandlePrintDTM;
    ShowOnTop();
  end;
end;

procedure TSimbaForm.MenuOpenClick(Sender: TObject);
begin
  SimbaScriptTabsForm.Open();
end;

procedure TSimbaForm.MenuFindClick(Sender: TObject);
begin
  SimbaScriptTabsForm.Find();
end;

procedure TSimbaForm.MenuItemFindNextClick(Sender: TObject);
begin
  SimbaScriptTabsForm.FindNext();
end;

procedure TSimbaForm.MenuItemFindPrevClick(Sender: TObject);
begin
  SimbaScriptTabsForm.FindPrevious();
end;

procedure TSimbaForm.MenuReplaceClick(Sender: TObject);
begin
  SimbaScriptTabsForm.Replace();
end;

procedure TSimbaForm.MenuPasteClick(Sender: TObject);
begin
  if (SimbaScriptTabsForm.CurrentEditor <> nil) then
    SimbaScriptTabsForm.CurrentEditor.PasteFromClipboard();
end;

procedure TSimbaForm.MenuRedoClick(Sender: TObject);
begin
  if (SimbaScriptTabsForm.CurrentEditor <> nil) then
    SimbaScriptTabsForm.CurrentEditor.Redo();
end;

procedure TSimbaForm.MenuSaveClick(Sender: TObject);
begin
  if (SimbaScriptTabsForm.CurrentTab <> nil) then
    SimbaScriptTabsForm.CurrentTab.Save(SimbaScriptTabsForm.CurrentTab.ScriptFileName);
end;

procedure TSimbaForm.MenuSelectAllClick(Sender: TObject);
begin
  if (SimbaScriptTabsForm.CurrentEditor <> nil) then
    SimbaScriptTabsForm.CurrentEditor.SelectAll();
end;

procedure TSimbaForm.MenuUndoClick(Sender: TObject);
begin
  if (SimbaScriptTabsForm.CurrentEditor <> nil) then
    SimbaScriptTabsForm.CurrentEditor.Undo();
end;

procedure TSimbaForm.MenuItemResetLayoutClick(Sender: TObject);
begin
  if MessageDlg('Reset to default layout? This will happen when Simba is next restarted.', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    FDockingReset := True
  else
    FDockingReset := False;
end;

procedure TSimbaForm.MenuItemConsoleClick(Sender: TObject);
begin
  SimbaSettings.GUI.ConsoleVisible.Value := TMenuItem(Sender).Checked;
end;

procedure TSimbaForm.MenuItemLockLayoutClick(Sender: TObject);
begin
  SimbaSettings.GUI.LockLayout.Value := TMenuItem(Sender).Checked;
end;

procedure TSimbaForm.MenuItemTrayIconClick(Sender: TObject);
begin
  SimbaSettings.GUI.TrayIconVisible.Value := TMenuItem(Sender).Checked;
end;

procedure TSimbaForm.TimerTimer(Sender: TObject);
var
  Tab: TSimbaScriptTab;
begin
  Tab := SimbaScriptTabsForm.CurrentTab;
  if (Tab = nil) then
    Exit;

  case Tab.ScriptState of
    STATE_PAUSED:
      begin
        ToolbarButtonRun.Enabled := True;
        ToolbarButtonPause.Enabled := False;
        ToolbarButtonCompile.Enabled := True;

        StopButtonStop.Enabled := True;
        StopButtonStop.ImageIndex := IMAGE_STOP;

        StatusPanelState.Caption := ' Paused';
      end;

    STATE_STOP:
      begin
        ToolbarButtonRun.Enabled := False;
        ToolbarButtonPause.Enabled := False;
        ToolbarButtonCompile.Enabled := False;

        StopButtonStop.Enabled := True;
        StopButtonStop.ImageIndex := IMAGE_POWER;

        StatusPanelState.Caption := ' Stopping';
      end;

    STATE_RUNNING:
      begin
        ToolbarButtonRun.Enabled := False;
        ToolbarButtonPause.Enabled := True;
        ToolbarButtonCompile.Enabled := False;

        StopButtonStop.Enabled := True;
        StopButtonStop.ImageIndex := IMAGE_STOP;

        StatusPanelState.Caption := ' ' + TimeStamp(Tab.ScriptTimeRunning);
      end;

    STATE_NONE:
      begin
        ToolbarButtonRun.Enabled := True;
        ToolbarButtonPause.Enabled := False;
        ToolbarButtonCompile.Enabled := True;

        StopButtonStop.Enabled := False;
        StopButtonStop.ImageIndex := IMAGE_STOP;

        StatusPanelState.Caption := ' Stopped';
      end;
  end;

  try
    if not FWindowSelection.IsValid() then
      FWindowSelection := GetDesktopWindow();

    with FWindowSelection.GetRelativeCursorPos() do
      StatusPanelCursor.Caption := '  (' + IntToStr(X) + ', ' + IntToStr(Y) + ')';
  except
    on E: Exception do
      DebugLn(E.Message);
  end;
end;

procedure TSimbaForm.ToolbarButtonPackagesClick(Sender: TObject);
begin
  SimbaPackageForm.Show();
end;

procedure TSimbaForm.ToolbarButtonSaveAllClick(Sender: TObject);
var
  I: Integer;
begin
  for I := SimbaScriptTabsForm.TabCount - 1 downto 0 do
    if SimbaScriptTabsForm.Tabs[I].ScriptChanged then
    begin
      if (SimbaScriptTabsForm.Tabs[I].ScriptFileName = '') then
        SimbaScriptTabsForm.Tabs[I].Show();

      SimbaScriptTabsForm.Tabs[I].Save(SimbaScriptTabsForm.Tabs[I].ScriptFileName);
    end;
end;

procedure TSimbaForm.MenuSaveAsClick(Sender: TObject);
begin
  if (SimbaScriptTabsForm.CurrentTab <> nil) then
    SimbaScriptTabsForm.CurrentTab.Save('');
end;

procedure TSimbaForm.MenuItemBitmapConvClick(Sender: TObject);
begin
  SimbaBitmapConversionForm.Show();
end;

procedure TSimbaForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if (not SimbaScriptTabsForm.CloseAllTabs()) then
    CloseAction := caNone
  else
  begin
    CloseAction := caFree;

    if FDockingReset then
    begin
      SimbaSettings.GUI.Layout.Value := '';
      SimbaSettings.GUI.LockLayout.Value := False;
    end else
      SimbaSettings.GUI.Layout.Value := DockMaster.SaveLayout();

    Visible := False;
  end;
end;

procedure TSimbaForm.HandleEditorChanged(Sender: TObject);
begin
  with Sender as TSimbaScriptTab do
  begin
    if (ScriptFileName <> '') then
      StatusPanelFileName.Caption := ' ' + ScriptFileName
    else
      StatusPanelFileName.Caption := ' ' + ScriptTitle;

    StatusPanelCaret.Caption := ' Line ' + IntToStr(Editor.CaretY) + ', Col ' + IntToStr(Editor.CaretX);

    MenuItemSaveAll.Enabled := PageControl.PageCount > 1;
    ToolbarButtonSaveAll.Enabled := PageControl.PageCount > 1;
  end;
end;

procedure TSimbaForm.HandleEditorLoaded(Sender: TObject);
begin
  with Sender as TSimbaScriptTab do
  begin
    StatusPanelFileName.Caption := ' ' + ScriptFileName;

    if FRecentFiles.IndexOf(ScriptFileName) >= 0 then
      FRecentFiles.Delete(FRecentFiles.IndexOf(ScriptFileName));
    FRecentFiles.Insert(0, ScriptFileName);
    while (FRecentFiles.Count > 10) do
      FRecentFiles.Pop();
  end;
end;

procedure TSimbaForm.HandleEditorCaretChange(Sender: TObject);
begin
  with Sender as TSimbaEditor do
    StatusPanelCaret.Caption := ' Line ' + IntToStr(CaretY) + ', Col ' + IntToStr(CaretX);
end;

procedure TSimbaForm.HandleEditorSearch(Sender: TObject);
begin
  with Sender as TSimbaEditor do
  begin
    if (ModifiedLinesGutter.LineMarkCount = 0) then
      StatusPanelFileName.Caption := Format(' Found %d matches.', [ModifiedLinesGutter.LineMarkCount])
    else
      StatusPanelFileName.Caption := Format(' Found %d matches. Use F3 (Forward) or Shift + F3 (Backwards) to traverse matches', [ModifiedLinesGutter.LineMarkCount]);
  end;
end;

procedure TSimbaForm.MenuEditClick(Sender: TObject);
begin
  if SimbaScriptTabsForm.CurrentEditor <> nil then
    with SimbaScriptTabsForm.CurrentEditor do
    begin
      MenuItemCut.Enabled := SelText <> '';
      MenuItemCopy.Enabled := SelText <> '';
      MenuItemPaste.Enabled := SelText <> '';
    end;
end;

procedure TSimbaForm.MenuItemCloseTabsClick(Sender: TObject);
begin
  SimbaScriptTabsForm.CloseAllTabs();
end;

procedure TSimbaForm.MenuItemReportBugClick(Sender: TObject);
begin
  OpenURL(SIMBA_BUGS_URL);
end;

procedure TSimbaForm.MenuItemSettingsClick(Sender: TObject);
begin
  SimbaSettingsForm.ShowModal();
end;

procedure TSimbaForm.TrayIconClick(Sender: TObject);
begin
  Self.ShowOnTop();
  if Self.CanSetFocus() then
    Self.SetFocus();
end;

procedure TSimbaForm.ToolbarButtonColorPickerClick(Sender: TObject);
begin
  try
    with TSimbaColorPicker.Create(FWindowSelection) do
    try
      if not Picked then
        Exit;

      SimbaColorPickerHistoryForm.Add(Point, Color, True);
      SimbaOutputForm.Add('Color picked: ' + IntToStr(Color) + ' at (' + IntToStr(Point.X) + ', ' + IntToStr(Point.Y) + ')');
    finally
      Free();
    end;

    Application.QueueAsyncCall(@ShowColorPickerHistoryASync, 0);
  except
    on E: Exception do
      ShowMessage('Exception while picking color: ' + E.Message + '(' + E.ClassName + ')');
  end;
end;

procedure TSimbaForm.ToolbarButtonSelectTargetClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Lines: TStringList;
begin
  if (Button = mbLeft) then
  begin
    Lines := TStringList.Create();

    try
      with TSimbaWindowSelector.Create() do
      try
        Lines.Add('Window Selected: %d', [Selected]);
        Lines.Add(' - Dimensions: %dx%d', [Selected.GetBounds().Width - 1, Selected.GetBounds().Height - 1]);
        Lines.Add(' - Title: "%s"', [Selected.GetTitle()]);
        Lines.Add(' - Class: "%s"', [Selected.GetClassName()]);
        Lines.Add(' - PID: %d (%s bit)', [Selected.GetPID, BoolToStr(SimbaProcess.IsProcess64Bit(Selected.GetPID()), '64', '32')]);
        Lines.Add(' - Executable: "%s"', [SimbaProcess.GetProcessPath(Selected.GetPID())]);

        FWindowSelection := Selected;
        FProcessSelection := Selected.GetPID();
      finally
        Free();
      end;
    except
      on E: Exception do
        ShowMessage('Exception while selecting window: ' + E.Message + ' (' + E.ClassName + ')');
    end;

    SimbaOutputForm.Add(Lines);

    Lines.Free();
  end;
end;

procedure TSimbaForm.SetupScriptTabs(Sender: TObject);
begin
  SimbaScriptTabsForm.OnEditorLoaded := @HandleEditorLoaded;
  SimbaScriptTabsForm.OnEditorChanged := @HandleEditorChanged;
  SimbaScriptTabsForm.OnEditorCaretChanged := @HandleEditorCaretChange;
  SimbaScriptTabsForm.OnEditorSearch := @HandleEditorSearch;
  SimbaScriptTabsForm.AddTab();
end;

procedure TSimbaForm.SetupDocking(Sender: TObject);
begin
  BeginFormUpdate();

  try
    DockMaster.BeginUpdate();
    DockMaster.HeaderClass := TSimbaAnchorDockHeader;
    DockMaster.SplitterClass := TSimbaAnchorDockSplitter;
    DockMaster.SiteClass := TSimbaAnchorDockHostSite;
    DockMaster.HideHeaderCaptionFloatingControl := False;
    DockMaster.HeaderAlignTop := $FFFFFF;
    DockMaster.PageAreaInPercent := 0;
    DockMaster.HeaderHint := 'Use the mouse to drag and dock this window';
    DockMaster.MakeDockPanel(DockPanel, admrpChild);

    DockMaster.MakeDockable(SimbaScriptTabsForm, MenuItemEditor);
    DockMaster.MakeDockable(SimbaOutputForm, MenuItemOutput);
    DockMaster.MakeDockable(SimbaFileBrowserForm, MenuItemFileBrowser);
    DockMaster.MakeDockable(SimbaFunctionListForm, MenuItemFunctionList);
    DockMaster.MakeDockable(SimbaNotesForm, MenuItemNotes);
    DockMaster.MakeDockable(SimbaDebugImageForm, MenuItemDebugImage);
    DockMaster.MakeDockable(SimbaColorPickerHistoryForm, MenuItemColourHistory);

    if (SimbaSettings.GUI.Layout.Value = '') then
    begin
      DockMaster.GetAnchorSite(SimbaFileBrowserForm).Width := 175;
      DockMaster.GetAnchorSite(SimbaFunctionListForm).Width := 175;
      DockMaster.GetAnchorSite(SimbaOutputForm).Height := 80;

      DockMaster.ManualDock(DockMaster.GetAnchorSite(SimbaScriptTabsForm), DockPanel, alClient);
      DockMaster.ManualDock(DockMaster.GetAnchorSite(SimbaOutputForm), DockPanel, alBottom);
      DockMaster.ManualDock(DockMaster.GetAnchorSite(SimbaFunctionListForm), DockPanel, alLeft);
      DockMaster.ManualDock(DockMaster.GetAnchorSite(SimbaFileBrowserForm), DockPanel, alRight);

      DockMaster.MakeVisible(SimbaScriptTabsForm, False);
      DockMaster.MakeVisible(SimbaOutputForm, False);
      DockMaster.MakeVisible(SimbaFunctionListForm, False);
      DockMaster.MakeVisible(SimbaFileBrowserForm, False);

      Width := 1250;
      Height := 850;
    end else
      DockMaster.LoadLayout(SimbaSettings.GUI.Layout.Value);
  finally
    DockMaster.EndUpdate();

    EndFormUpdate();
  end;

  if (SimbaSettings.GUI.Layout.Value = '') then
  begin
    Position := poScreenCenter;

    EnsureVisible();
  end;
end;

procedure TSimbaForm.SetupCompleted(Sender: TObject);
begin
  Timer.Enabled := True;

  if SimbaSettings.FirstLaunch then
    MenuItemAssociateScripts.Click();

  if (Application.ParamCount > 0) then
  begin
    if (Application.ParamCount = 1) and FileExists(Application.Params[1]) then
      SimbaScriptTabsForm.Open(Application.Params[1])
    else
    if Application.HasOption('open') and FileExists(Application.Params[Application.ParamCount]) then
    begin
      SimbaScriptTabsForm.Open(Application.Params[Application.ParamCount]);

      if Application.HasOption('compile') then
        ToolbarButtonCompile.Click();
      if Application.HasOption('run') then
        ToolbarButtonRun.Click();
    end;
  end;
end;

end.