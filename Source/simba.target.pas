{
  Author: Raymond van Venetië and Merlijn Wajer
  Project: Simba (https://github.com/MerlijnWajer/Simba)
  License: GNU General Public License (https://www.gnu.org/licenses/gpl-3.0)
}
unit simba.target;

{$i simba.inc}

// todo, autoactivate & addhandleroninvalidtarget & clientarea

interface

uses
  Classes, SysUtils,
  simba.mufasatypes, simba.bitmap,
  simba.target_eios, simba.target_window, simba.target_bitmap;

type
  {$PUSH}
  {$SCOPEDENUMS ON}
  ETargetType = (NONE, BITMAP, WINDOW, EIOS);
  ETargetTypes = set of ETargetType;
  {$POP}

  TTargetMethods = record
    GetDimensions: procedure(Target: Pointer; out W, H: Integer);
    GetImageData: function(Target: Pointer; X, Y, Width, Height: Integer; var Data: PColorBGRA; var DataWidth: Integer): Boolean;

    IsValid: function(Target: Pointer): Boolean;
    IsFocused: function(Target: Pointer): Boolean;
    Focus: function(Target: Pointer): Boolean;

    KeyDown: procedure(Target: Pointer; Key: KeyCode);
    KeyUp: procedure(Target: Pointer; Key: KeyCode);
    KeySend: procedure(Target: Pointer; Key: Char; KeyDownTime, KeyUpTime, ModifierDownTime, ModifierUpTime: Integer);
    KeyPressed: function(Target: Pointer; Key: KeyCode): Boolean;

    MouseTeleport: procedure(Target: Pointer; P: TPoint);
    MousePosition: function(Target: Pointer): TPoint;
    MousePressed: function(Target: Pointer; Button: MouseButton): Boolean;
    MouseDown: procedure(Target: Pointer; Button: MouseButton);
    MouseUp: procedure(Target: Pointer; Button: MouseButton);
    MouseScroll: procedure(Target: Pointer; Scrolls: Integer);
  end;

const
  TargetName: array[ETargetType] of String = ('NONE', 'BITMAP', 'WINDOW', 'EIOS');

type
  PSimbaTarget = ^TSimbaTarget;
  TSimbaTarget = packed record
  public
    FTargetType: ETargetType;
    FTarget: Pointer;
    FTargetBitmap: TMufasaBitmap;
    FTargetWindow: TWindowHandle;
    FTargetEIOS: TEIOSTarget;
    FMethods: TTargetMethods; // Targets need to provide these. They are filled in SetWindow,SetEIOS etc.

    procedure ChangeTarget(TargetType: ETargetType);
    function HasMethod(Method: Pointer; Name: String): Boolean;
  public
    function GetWindowTarget: TWindowHandle;
    function IsWindowTarget: Boolean; overload;
    function IsWindowTarget(out Window: TWindowHandle): Boolean; overload;
    function IsBitmapTarget: Boolean; overload;
    function IsBitmapTarget(out Bitmap: TMufasaBitmap): Boolean; overload;
    function IsEIOSTarget: Boolean;

    function IsValid: Boolean;
    function IsFocused: Boolean;
    function Focus: Boolean;

    procedure GetDimensions(out W, H: Integer);
    function GetWidth: Integer;
    function GetHeight: Integer;

    function GetImage(Bounds: TBox): TMufasaBitmap;

    procedure SetDesktop;
    procedure SetWindow(Window: TWindowHandle);
    procedure SetBitmap(Bitmap: TMufasaBitmap);
    procedure SetEIOS(FileName, Args: String);

    function MousePressed(Button: MouseButton): Boolean;
    function MousePosition: TPoint;
    procedure MouseTeleport(P: TPoint);
    procedure MouseUp(Button: MouseButton);
    procedure MouseDown(Button: MouseButton);
    procedure MouseScroll(Scrolls: Integer);

    procedure KeyDown(Key: KeyCode);
    procedure KeyUp(Key: KeyCode);
    procedure KeySend(Key: Char; KeyDownTime, KeyUpTime, ModifierDownTime, ModifierUpTime: Integer);
    function KeyPressed(Key: KeyCode): Boolean;

    function ValidateBounds(var Bounds: TBox): Boolean;
    function GetImageData(var Bounds: TBox; var Data: PColorBGRA; var DataWidth: Integer): Boolean;
    procedure FreeImageData(var Data: PColorBGRA);

    class operator Initialize(var Self: TSimbaTarget);
  end;

implementation

uses
  simba.nativeinterface;

procedure TSimbaTarget.ChangeTarget(TargetType: ETargetType);
begin
  FTargetType := TargetType;
  FMethods := Default(TTargetMethods);
end;

function TSimbaTarget.HasMethod(Method: Pointer; Name: String): Boolean;
begin
  if (Method = nil) then
    raise Exception.CreateFmt('Target "%s" cannot %s', [TargetName[FTargetType], Name]);

  Result := True;
end;

function TSimbaTarget.GetWindowTarget: TWindowHandle;
begin
  if (FTargetType = ETargetType.WINDOW) then
    Result := FTargetWindow
  else
    Result := 0;
end;

function TSimbaTarget.IsWindowTarget: Boolean;
begin
  Result := FTargetType = ETargetType.WINDOW;
end;

function TSimbaTarget.IsWindowTarget(out Window: TWindowHandle): Boolean;
begin
  Result := FTargetType = ETargetType.WINDOW;
  if Result then
    Window := FTargetWindow;
end;

function TSimbaTarget.IsBitmapTarget: Boolean;
begin
  Result := FTargetType = ETargetType.BITMAP;
end;

function TSimbaTarget.IsBitmapTarget(out Bitmap: TMufasaBitmap): Boolean;
begin
  Result := FTargetType = ETargetType.BITMAP;
  if Result then
    Bitmap := FTargetBitmap;
end;

function TSimbaTarget.IsEIOSTarget: Boolean;
begin
  Result := FTargetType = ETargetType.EIOS;
end;

function TSimbaTarget.IsValid: Boolean;
begin
  if HasMethod(@FMethods.IsValid, 'IsValid') then
    Result := FMethods.IsValid(FTarget);
end;

function TSimbaTarget.IsFocused: Boolean;
begin
  if HasMethod(@FMethods.IsFocused, 'IsFocused') then
    Result := FMethods.IsFocused(FTarget);
end;

function TSimbaTarget.Focus: Boolean;
begin
  if HasMethod(@FMethods.Focus, 'Focus') then
    Result := FMethods.Focus(FTarget);
end;

procedure TSimbaTarget.GetDimensions(out W, H: Integer);
begin
  if HasMethod(@FMethods.GetDimensions, 'GetDimensions') then
    FMethods.GetDimensions(FTarget, W, H);
end;

function TSimbaTarget.GetWidth: Integer;
var
  _: Integer;
begin
  GetDimensions(Result, _);
end;

function TSimbaTarget.GetHeight: Integer;
var
  _: Integer;
begin
  GetDimensions(_, Result);
end;

function TSimbaTarget.GetImage(Bounds: TBox): TMufasaBitmap;
var
  Data: PColorBGRA;
  DataWidth: Integer;
begin
  if GetImageData(Bounds, Data, DataWidth) then
    Result := TMufasaBitmap.CreateFromData(Bounds.Width, Bounds.Height, Data, DataWidth)
  else
    Result := TMufasaBitmap.Create();
end;

procedure TSimbaTarget.SetDesktop;
begin
  SetWindow(SimbaNativeInterface.GetDesktopWindow());
end;

procedure TSimbaTarget.SetWindow(Window: TWindowHandle);
begin
  ChangeTarget(ETargetType.WINDOW);

  FTargetWindow := Window;
  FTarget := @FTargetWindow;

  FMethods.Focus := @WindowTarget_Focus;
  FMethods.IsFocused := @WindowTarget_IsFocused;
  FMethods.IsValid := @WindowTarget_IsValid;

  FMethods.KeyDown := @WindowTarget_KeyDown;
  FMethods.KeyUp := @WindowTarget_KeyUp;
  FMethods.KeySend := @WindowTarget_KeySend;
  FMethods.KeyPressed := @WindowTarget_KeyPressed;

  FMethods.MouseTeleport := @WindowTarget_MouseTeleport;
  FMethods.MousePosition := @WindowTarget_MousePosition;
  FMethods.MousePressed := @WindowTarget_MousePressed;
  FMethods.MouseDown := @WindowTarget_MouseDown;
  FMethods.MouseUp := @WindowTarget_MouseUp;
  FMethods.MouseScroll := @WindowTarget_MouseScroll;

  FMethods.GetDimensions := @WindowTarget_GetDimensions;
  FMethods.GetImageData := @WindowTarget_GetImageData;
end;

procedure TSimbaTarget.SetBitmap(Bitmap: TMufasaBitmap);
begin
  ChangeTarget(ETargetType.BITMAP);

  FTargetBitmap := Bitmap;
  FTarget := FTargetBitmap;

  FMethods.GetDimensions := @BitmapTarget_GetDimensions;
  FMethods.GetImageData := @BitmapTarget_GetImageData;
end;

procedure TSimbaTarget.SetEIOS(FileName, Args: String);
begin
  ChangeTarget(ETargetType.EIOS);

  FTargetEIOS := LoadEIOS(FileName, Args);
  FTarget := @FTargetEIOS;

  FMethods.KeyDown := @EIOSTarget_KeyDown;
  FMethods.KeyUp := @EIOSTarget_KeyUp;
  FMethods.KeySend := @EIOSTarget_KeySend;
  FMethods.KeyPressed := @EIOSTarget_KeyPressed;

  FMethods.MouseTeleport := @EIOSTarget_MouseTeleport;
  FMethods.MousePosition := @EIOSTarget_MousePosition;
  FMethods.MousePressed := @EIOSTarget_MousePressed;
  FMethods.MouseDown := @EIOSTarget_MouseDown;
  FMethods.MouseUp := @EIOSTarget_MouseUp;
  FMethods.MouseScroll := @EIOSTarget_MouseScroll;

  FMethods.GetDimensions := @EIOSTarget_GetDimensions;
  FMethods.GetImageData := @EIOSTarget_GetImageData;
end;

function TSimbaTarget.MousePressed(Button: MouseButton): Boolean;
begin
  if HasMethod(@FMethods.MousePressed, 'MousePressed') then
    Result := FMethods.MousePressed(FTarget, Button);
end;

function TSimbaTarget.MousePosition: TPoint;
begin
  if HasMethod(@FMethods.MousePosition, 'MousePosition') then
    Result := FMethods.MousePosition(FTarget);
end;

procedure TSimbaTarget.MouseTeleport(P: TPoint);
begin
  if HasMethod(@FMethods.MouseTeleport, 'MouseTeleport') then
    FMethods.MouseTeleport(FTarget, P);
end;

procedure TSimbaTarget.MouseUp(Button: MouseButton);
begin
  if HasMethod(@FMethods.MouseUp, 'MouseUp') then
    FMethods.MouseUp(FTarget, Button);
end;

procedure TSimbaTarget.MouseDown(Button: MouseButton);
begin
  if HasMethod(@FMethods.MouseDown, 'MouseDown') then
    FMethods.MouseDown(FTarget, Button);
end;

procedure TSimbaTarget.MouseScroll(Scrolls: Integer);
begin
  if HasMethod(@FMethods.MouseScroll, 'MouseScroll') then
    FMethods.MouseScroll(FTarget, Scrolls);
end;

procedure TSimbaTarget.KeyDown(Key: KeyCode);
begin
  if HasMethod(@FMethods.KeyDown, 'KeyDown') then
    FMethods.KeyDown(FTarget, Key);
end;

procedure TSimbaTarget.KeyUp(Key: KeyCode);
begin
  if HasMethod(@FMethods.KeyDown, 'KeyUp') then
    FMethods.KeyDown(FTarget, Key);
end;

procedure TSimbaTarget.KeySend(Key: Char; KeyDownTime, KeyUpTime, ModifierDownTime, ModifierUpTime: Integer);
begin
  if HasMethod(@FMethods.KeySend, 'KeySend') then
    FMethods.KeySend(FTarget, Key, KeyDownTime, KeyUpTime, ModifierDownTime, ModifierUpTime);
end;

function TSimbaTarget.KeyPressed(Key: KeyCode): Boolean;
begin
  if HasMethod(@FMethods.KeyPressed, 'KeyPressed') then
    Result := FMethods.KeyPressed(FTarget, Key);
end;

function TSimbaTarget.ValidateBounds(var Bounds: TBox): Boolean;
var
  Width, Height: Integer;
begin
  GetDimensions(Width, Height);

  if (Bounds.X1 = -1) and (Bounds.Y1 = -1) and (Bounds.X2 = -1) and (Bounds.Y2 = -1) then
  begin
    Bounds.X1 := 0;
    Bounds.Y1 := 0;
    Bounds.X2 := Width - 1;
    Bounds.Y2 := Height - 1;
  end else
  begin
    if (Bounds.X1 < 0)       then Bounds.X1 := 0;
    if (Bounds.Y1 < 0)       then Bounds.Y1 := 0;
    if (Bounds.X2 >= Width)  then Bounds.X2 := Width - 1;
    if (Bounds.Y2 >= Height) then Bounds.Y2 := Height - 1;
  end;

  Result := (Bounds.Width > 0) and (Bounds.Height > 0);
end;

function TSimbaTarget.GetImageData(var Bounds: TBox; var Data: PColorBGRA; var DataWidth: Integer): Boolean;
begin
  Data := nil;
  if HasMethod(@FMethods.GetImageData, 'GetImageData') then
    Result := ValidateBounds(Bounds) and FMethods.GetImageData(FTarget, Bounds.X1, Bounds.Y1, Bounds.Width, Bounds.Height, Data, DataWidth);
end;

procedure TSimbaTarget.FreeImageData(var Data: PColorBGRA);
begin
  if (FTargetType in [ETargetType.WINDOW]) then
    FreeMem(Data);
end;

class operator TSimbaTarget.Initialize(var Self: TSimbaTarget);
begin
  Self := Default(TSimbaTarget);
end;

end.

