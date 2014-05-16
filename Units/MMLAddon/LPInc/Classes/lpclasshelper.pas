unit lpClassHelper;

{$mode objfpc}{$H+}
{$I Simba.inc}

interface

uses
  Classes, SysUtils, lpcompiler, lptypes, lpvartypes, Controls, StdCtrls;

type
  TLapeCompilerHelper = class helper for TLapeCompiler
  public
    procedure addClass(const Name: string; const Parent: string = 'TObject');
    procedure addClassVar(const Obj, Item, Typ: string; const Read: Pointer; const Write: Pointer = nil; const Arr: boolean = False; const ArrType: string = 'UInt32');
  end;

  generic TRegisterWrapper<_T> = class(TComponent)
  private
    FMethod: _T;
  public
    property InternalMethod: _T read FMethod write FMethod;
  end;

  PDrawItemEventWrapper = ^TDrawItemEventWrapper;
  TDrawItemEventWrapper = procedure(Control: TControl; Index: Integer; ARect: TRect; State: TOwnerDrawState); cdecl;
  TOnDrawItemWrapper = class(specialize TRegisterWrapper<TDrawItemEventWrapper>)
  public
    procedure DrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState); register;
  end;

  PMouseMoveEventWrapper = ^TMouseMoveEventWrapper;
  TMouseMoveEventWrapper = procedure(Sender: TObject; Shift: TShiftState; X, Y: Integer); cdecl;
  TOnMouseMoveWrapper = class(specialize TRegisterWrapper<TMouseMoveEventWrapper>)
  public
    procedure MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer); register;
  end;

implementation

procedure TLapeCompilerHelper.addClass(const Name: string; const Parent: string = 'TObject');
begin
  addGlobalType(Format('type %s', [Parent]), Name);
end;

procedure TLapeCompilerHelper.addClassVar(const Obj, Item, Typ: string; const Read: Pointer; const Write: Pointer = nil; const Arr: boolean = False; const ArrType: string = 'UInt32');
var
  Param: string;
begin
  Param := '';
  if Arr then
    Param := 'const Index: ' + ArrType;

  if (Assigned(Read)) then
    addGlobalFunc(Format('function %s.get%s(%s): %s;', [Obj, Item, Param, Typ]), Read);

  if Arr then
    Param += '; ';

  if (Assigned(Write)) then
    addGlobalFunc(Format('procedure %s.set%s(%sconst Value: %s);', [Obj, Item, Param, Typ]), Write);
end;

procedure TOnDrawItemWrapper.DrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState); register;
begin
  if (Assigned(FMethod)) then
    FMethod(TControl(Control), Index, ARect, State);
end;

procedure TOnMouseMoveWrapper.MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer); register;
begin
  if (Assigned(FMethod)) then
    FMethod(Sender, Shift, X, Y);
end;

end.

