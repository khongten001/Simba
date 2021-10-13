procedure _LapeMaskFromText(const Params: PParamArray; const Result: Pointer); {$IFDEF Lape_CDECL}cdecl;{$ENDIF}
begin
  with SimbaScript.Client do
    PMask(Result)^ := MOCR.TextToMask(PString(Params^[0])^, PString(Params^[1])^);
end;

procedure _LapeTPAFromText(const Params: PParamArray; const Result: Pointer); {$IFDEF Lape_CDECL}cdecl;{$ENDIF}
begin
  with SimbaScript.Client do
    PPointArray(Result)^ := MOCR.TextToFontTPA(PString(Params^[0])^, PString(Params^[1])^, PInt32(Params^[2])^, PInt32(Params^[3])^);
end;

procedure _LapeGetTextATPA(const Params: PParamArray; const Result: Pointer); {$IFDEF Lape_CDECL}cdecl;{$ENDIF}
begin
  with SimbaScript.Client do
    Pstring(Result)^ := MOCR.GetTextATPA(P2DPointArray(Params^[0])^, PInt32(Params^[1])^, Pstring(Params^[2])^);
end;

procedure _LapeGetTextAt(const Params: PParamArray; const Result: Pointer); {$IFDEF Lape_CDECL}cdecl;{$ENDIF}
begin
  with SimbaScript.Client do
    Pstring(Result)^ := MOCR.GetTextAt(PInt32(Params^[0])^, PInt32(Params^[1])^, PInt32(Params^[2])^, PInt32(Params^[3])^, PInt32(Params^[4])^, PInt32(Params^[5])^, PInt32(Params^[6])^, PInt32(Params^[7])^, Pstring(Params^[8])^);
end;

procedure _LapeGetTextAtEx(const Params: PParamArray; const Result: Pointer); {$IFDEF Lape_CDECL}cdecl;{$ENDIF}
begin
  with SimbaScript.Client do
    Pstring(Result)^ := MOCR.GetTextAt(PInt32(Params^[0])^, PInt32(Params^[1])^, PInt32(Params^[2])^, PInt32(Params^[3])^, PInt32(Params^[4])^, PInt32(Params^[5])^, PInt32(Params^[6])^, PInt32(Params^[7])^, PInt32(Params^[8])^, Pstring(Params^[9])^);
end;

procedure _LapeLoadSystemFont(const Params: PParamArray; const Result: Pointer); {$IFDEF Lape_CDECL}cdecl;{$ENDIF}
begin
  with SimbaScript.Client do
    Pboolean(Result)^ := MOCR.Fonts.LoadSystemFont(PFont(Params^[0])^, Pstring(Params^[1])^);
end;

procedure _LapeLoadFont(const Params: PParamArray; const Result: Pointer); {$IFDEF Lape_CDECL}cdecl;{$ENDIF}
begin
  with SimbaScript.Client do
    Pboolean(Result)^ := MOCR.Fonts.LoadFont(Pstring(Params^[0])^, Pboolean(Params^[1])^);
end;

procedure _LapeFreeFont(const Params: PParamArray; const Result: Pointer); {$IFDEF Lape_CDECL}cdecl;{$ENDIF}
begin
  with SimbaScript.Client do
    Pboolean(Result)^ := MOCR.Fonts.FreeFont(Pstring(Params^[0])^);
end;

procedure _LapeIsFontLoaded(const Params: PParamArray; const Result: Pointer); {$IFDEF Lape_CDECL}cdecl;{$ENDIF}
begin
  with SimbaScript.Client do
    PBoolean(Result)^ := MOCR.Fonts.IsFontLoaded(Pstring(Params^[0])^);
end;
