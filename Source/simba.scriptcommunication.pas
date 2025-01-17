{
  Author: Raymond van Venetië and Merlijn Wajer
  Project: Simba (https://github.com/MerlijnWajer/Simba)
  License: GNU General Public License (https://www.gnu.org/licenses/gpl-3.0)
}
unit simba.scriptcommunication;

{$i simba.inc}

interface

uses
  Classes, SysUtils, Forms, ExtCtrls, Graphics,
  simba.base, simba.ipc, simba.scripttab;

type
  TSimbaScriptInstanceCommunication = class(TSimbaIPCServer)
  protected
    FRunner: TSimbaScriptTabRunner;
    FMethods: array[ESimbaCommunicationMessage] of TProcedureOfObject;
    FParams: TMemoryStream;
    FResult: TMemoryStream;

    procedure OnMessage(MessageID: Integer; Params, Result: TMemoryStream); override;

    procedure GetScript;
    procedure SetSimbaTitle;

    procedure ShowTrayNotification;

    procedure GetSimbaPID;
    procedure GetSimbaTargetWindow;
    procedure GetSimbaTargetPID;

    procedure ScriptStateChanged;
    procedure ScriptError;

    procedure DebugImage_SetMaxSize;
    procedure DebugImage_Show;
    procedure DebugImage_Update;
    procedure DebugImage_Hide;
    procedure DebugImage_Display;
    procedure DebugImage_DisplayXY;
  public
    constructor Create(Runner: TSimbaScriptTabRunner); reintroduce;
  end;

implementation

uses
  simba.main, simba.debugimageform, simba.image_lazbridge,
  simba.threading, simba.ide_maintoolbar, simba.process;

procedure TSimbaScriptInstanceCommunication.OnMessage(MessageID: Integer; Params, Result: TMemoryStream);
var
  Message: ESimbaCommunicationMessage absolute MessageID;
begin
  FParams := Params;
  FResult := Result;

  FMethods[Message]();
end;

procedure TSimbaScriptInstanceCommunication.GetScript;
begin
  FResult.WriteAnsiString(FRunner.ScriptTitle);
  FResult.WriteAnsiString(FRunner.Script);
end;

procedure TSimbaScriptInstanceCommunication.SetSimbaTitle;

  procedure Execute;
  begin
    SimbaForm.Caption := FParams.ReadAnsiString();
  end;

begin
  RunInMainThread(@Execute);
end;

procedure TSimbaScriptInstanceCommunication.ShowTrayNotification;
var
  Title, Hint: String;
  Timeout: Integer;

  procedure Execute;
  begin
    SimbaForm.TrayIcon.BalloonTitle   := Title;
    SimbaForm.TrayIcon.BalloonHint    := Hint;
    SimbaForm.TrayIcon.BalloonTimeout := Timeout;
    SimbaForm.TrayIcon.ShowBalloonHint();
  end;

begin
  Title := FParams.ReadAnsiString;
  Hint  := FParams.ReadAnsiString;

  FParams.Read(Timeout, SizeOf(Integer));

  RunInMainThread(@Execute);
end;

// Threadsafe
procedure TSimbaScriptInstanceCommunication.GetSimbaPID;
begin
  FResult.Write(GetProcessID(), SizeOf(TProcessID));
end;

// Threadsafe
procedure TSimbaScriptInstanceCommunication.GetSimbaTargetWindow;
begin
  FResult.Write(SimbaMainToolBar.WindowSelection, SizeOf(TWindowHandle));
end;

// Threadsafe
procedure TSimbaScriptInstanceCommunication.GetSimbaTargetPID;
begin
  FResult.Write(SimbaMainToolBar.ProcessSelection, SizeOf(TProcessID));
end;

procedure TSimbaScriptInstanceCommunication.ScriptStateChanged;
var
  State: ESimbaScriptState;

  procedure Execute;
  begin
    FRunner.State := State;
  end;

begin
  FParams.Read(State, SizeOf(ESimbaScriptState));

  RunInMainThread(@Execute);
end;

procedure TSimbaScriptInstanceCommunication.ScriptError;
var
  Message, FileName: String;
  Line, Column: Integer;

  procedure Execute;
  begin
    FRunner.SetError(Message, FileName, Line, Column);
  end;

begin
  Message  := FParams.ReadAnsiString();
  FileName := FParams.ReadAnsiString();

  FParams.Read(Line, SizeOf(Integer));
  FParams.Read(Column, SizeOf(Integer));

  RunInMainThread(@Execute);
end;

procedure TSimbaScriptInstanceCommunication.DebugImage_SetMaxSize;
var
  Width, Height: Integer;

  procedure Execute;
  begin
    SimbaDebugImageForm.SetMaxSize(Width, Height);
  end;

begin
  FParams.Read(Width, SizeOf(Integer));
  FParams.Read(Height, SizeOf(Integer));

  RunInMainThread(@Execute);
end;

procedure TSimbaScriptInstanceCommunication.DebugImage_Show;
var
  EnsureVisible: Boolean;

  procedure Execute;
  begin
    DebugImage_Update();

    with SimbaDebugImageForm.ImageBox do
      SimbaDebugImageForm.SetSize(Background.Width, Background.Height, False, EnsureVisible);
  end;

begin
  FInputStream.Read(EnsureVisible, SizeOf(Boolean));

  RunInMainThread(@Execute);
end;

// Chunked data is sent. Row by row.
procedure TSimbaScriptInstanceCommunication.DebugImage_Update;

  // Modified from LazImage_FromData in simba.image_lazbridge
  // Could maybe do this off main thread with only Begin/EndUpdate synced
  procedure Execute;
  var
    Width, Height: Integer;
    Source, Dest: PByte;
    SourceUpper: PtrUInt;
    DestBytesPerLine, SourceBytesPerLine: Integer;
    SourcePtr, DestPtr: PByte;

    procedure BGR;
    var
      Y: Integer;
    begin
      for Y := 0 to Height - 1 do
      begin
        FInputStream.Read(Source^, SourceBytesPerLine);

        SourcePtr := Source;
        DestPtr   := Dest;

        while (PtrUInt(SourcePtr) < SourceUpper) do
        begin
          PColorRGB(DestPtr)^ := PColorRGB(SourcePtr)^; // Can just use first three bytes

          Inc(SourcePtr, SizeOf(TColorBGRA));
          Inc(DestPtr, SizeOf(TColorRGB));
        end;

        Inc(Dest, DestBytesPerLine);
      end;
    end;

    procedure BGRA;
    var
      Y: Integer;
    begin
      for Y := 0 to Height - 1 do
      begin
        FInputStream.Read(Source^, SourceBytesPerLine);

        Move(Source^, Dest^, DestBytesPerLine);
        Inc(Dest, DestBytesPerLine);
      end;
    end;

    procedure ARGB;
    var
      Y: Integer;
    begin
      for Y := 0 to Height - 1 do
      begin
        FInputStream.Read(Source^, SourceBytesPerLine);

        SourcePtr := Source;
        DestPtr   := Dest;

        while (PtrUInt(SourcePtr) < SourceUpper) do
        begin
          PUInt32(DestPtr)^ := SwapEndian(PUInt32(SourcePtr)^);

          Inc(SourcePtr, SizeOf(TColorBGRA));
          Inc(DestPtr, SizeOf(TColorARGB));
        end;

        Inc(Dest, DestBytesPerLine);
      end;
    end;

  var
    Bitmap: TBitmap;
  begin
    FInputStream.Read(Width, SizeOf(Integer));
    FInputStream.Read(Height, SizeOf(Integer));

    Bitmap := SimbaDebugImageForm.ImageBox.Background;
    Bitmap.BeginUpdate();
    Bitmap.SetSize(Width, Height);

    DestBytesPerLine := Bitmap.RawImage.Description.BytesPerLine;
    Dest             := Bitmap.RawImage.Data;

    SourceBytesPerLine := Width * SizeOf(TColorBGRA);
    Source             := GetMem(SourceBytesPerLine);
    SourceUpper        := PtrUInt(Source + SourceBytesPerLine);

    case LazImage_PixelFormat(Bitmap) of
      'BGR':  BGR();
      'BGRA': BGRA();
      'ARGB': ARGB();
    end;

    FreeMem(Source);

    Bitmap.EndUpdate();
  end;

begin
  RunInMainThread(@Execute);
end;

procedure TSimbaScriptInstanceCommunication.DebugImage_Hide;

  procedure Execute;
  begin
    SimbaDebugImageForm.Close();
  end;

begin
  RunInMainThread(@Execute);
end;

procedure TSimbaScriptInstanceCommunication.DebugImage_Display;
var
  Width, Height: Integer;

  procedure Execute;
  begin
    SimbaDebugImageForm.SetSize(Width, Height, True);
  end;

begin
  FParams.Read(Width, SizeOf(Integer));
  FParams.Read(Height, SizeOf(Integer));

  RunInMainThread(@Execute);
end;

procedure TSimbaScriptInstanceCommunication.DebugImage_DisplayXY;
var
  X, Y, Width, Height: Integer;

  procedure Execute;
  begin
    SimbaDebugImageForm.Left := X;
    SimbaDebugImageForm.Top  := Y;
    SimbaDebugImageForm.SetSize(Width, Height, True);
  end;

begin
  FParams.Read(X, SizeOf(Integer));
  FParams.Read(Y, SizeOf(Integer));
  FParams.Read(Width, SizeOf(Integer));
  FParams.Read(Height, SizeOf(Integer));

  RunInMainThread(@Execute);
end;

constructor TSimbaScriptInstanceCommunication.Create(Runner: TSimbaScriptTabRunner);
begin
  inherited Create(Runner);

  FRunner := Runner;

  FMethods[ESimbaCommunicationMessage.SCRIPT]                := @GetScript;
  FMethods[ESimbaCommunicationMessage.SIMBA_TITLE]           := @SetSimbaTitle;
  FMethods[ESimbaCommunicationMessage.SIMBA_PID]             := @GetSimbaPID;
  FMethods[ESimbaCommunicationMessage.SIMBA_TARGET_PID]      := @GetSimbaTargetPID;
  FMethods[ESimbaCommunicationMessage.SIMBA_TARGET_WINDOW]   := @GetSimbaTargetWindow;
  FMethods[ESimbaCommunicationMessage.SCRIPT_ERROR]          := @ScriptError;
  FMethods[ESimbaCommunicationMessage.SCRIPT_STATE_CHANGE]   := @ScriptStateChanged;
  FMethods[ESimbaCommunicationMessage.TRAY_NOTIFICATION]     := @ShowTrayNotification;
  FMethods[ESimbaCommunicationMessage.DEBUGIMAGE_MAXSIZE]    := @DebugImage_SetMaxSize;
  FMethods[ESimbaCommunicationMessage.DEBUGIMAGE_SHOW]       := @DebugImage_Show;
  FMethods[ESimbaCommunicationMessage.DEBUGIMAGE_UPDATE]     := @DebugImage_Update;
  FMethods[ESimbaCommunicationMessage.DEBUGIMAGE_HIDE]       := @DebugImage_Hide;
  FMethods[ESimbaCommunicationMessage.DEBUGIMAGE_DISPLAY]    := @DebugImage_Display;
  FMethods[ESimbaCommunicationMessage.DEBUGIMAGE_DISPLAY_XY] := @DebugImage_DisplayXY;
end;

end.

