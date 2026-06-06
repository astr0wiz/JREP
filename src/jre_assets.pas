unit jre_assets;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, fgl,
  jre_renderer, jre_audio;

type
  TTextureMap = specialize TFPGMap<string, TTexture>;
  TFontKey    = string;
  TFontMap    = specialize TFPGMap<TFontKey, TFont>;
  TSoundMap   = specialize TFPGMap<string, TSound>;
  TMusicMap   = specialize TFPGMap<string, TMusic>;

  TJREAssets = class
  private
    FRenderer: TJRERenderer;
    FAudio:    TJREAudio;
    FTextures: TTextureMap;
    FFonts:    TFontMap;
    FSounds:   TSoundMap;
    FMusic:    TMusicMap;
    FBasePath: string;
    function Resolve(const Path: string): string;
    function FontKey(const Path: string; Size: Integer): string;
  public
    constructor Create(ARenderer: TJRERenderer; AAudio: TJREAudio;
      const ABasePath: string = '');
    destructor Destroy; override;

    function GetTexture(const Name, Path: string): TTexture;
    function GetFont(const Name, Path: string; Size: Integer): TFont;
    function GetSound(const Name, Path: string): TSound;
    function GetMusic(const Name, Path: string): TMusic;
    procedure Unload(const Name: string);
    procedure UnloadAll;

    property BasePath: string read FBasePath write FBasePath;
  end;

implementation

constructor TJREAssets.Create(ARenderer: TJRERenderer; AAudio: TJREAudio;
  const ABasePath: string);
begin
  FRenderer := ARenderer;
  FAudio    := AAudio;
  FBasePath := ABasePath;
  FTextures := TTextureMap.Create;
  FFonts    := TFontMap.Create;
  FSounds   := TSoundMap.Create;
  FMusic    := TMusicMap.Create;
end;

destructor TJREAssets.Destroy;
begin
  UnloadAll;
  FTextures.Free;
  FFonts.Free;
  FSounds.Free;
  FMusic.Free;
  inherited;
end;

function TJREAssets.Resolve(const Path: string): string;
begin
  if FBasePath <> '' then
    Result := IncludeTrailingPathDelimiter(FBasePath) + Path
  else
    Result := Path;
end;

function TJREAssets.FontKey(const Path: string; Size: Integer): string;
begin
  Result := Path + '|' + IntToStr(Size);
end;

function TJREAssets.GetTexture(const Name, Path: string): TTexture;
var
  Idx: Integer;
begin
  Idx := FTextures.IndexOf(Name);
  if Idx >= 0 then
    Result := FTextures.Data[Idx]
  else
  begin
    Result := FRenderer.LoadTexture(Resolve(Path));
    FTextures.Add(Name, Result);
  end;
end;

function TJREAssets.GetFont(const Name, Path: string; Size: Integer): TFont;
var
  Idx: Integer;
begin
  Idx := FFonts.IndexOf(Name);
  if Idx >= 0 then
    Result := FFonts.Data[Idx]
  else
  begin
    Result := FRenderer.LoadFont(Resolve(Path), Size);
    FFonts.Add(Name, Result);
  end;
end;

function TJREAssets.GetSound(const Name, Path: string): TSound;
var
  Idx: Integer;
begin
  Idx := FSounds.IndexOf(Name);
  if Idx >= 0 then
    Result := FSounds.Data[Idx]
  else
  begin
    Result := FAudio.LoadSound(Resolve(Path));
    FSounds.Add(Name, Result);
  end;
end;

function TJREAssets.GetMusic(const Name, Path: string): TMusic;
var
  Idx: Integer;
begin
  Idx := FMusic.IndexOf(Name);
  if Idx >= 0 then
    Result := FMusic.Data[Idx]
  else
  begin
    Result := FAudio.LoadMusic(Resolve(Path));
    FMusic.Add(Name, Result);
  end;
end;

procedure TJREAssets.Unload(const Name: string);
var
  Idx: Integer;
  T: TTexture;
  F: TFont;
  S: TSound;
  M: TMusic;
begin
  Idx := FTextures.IndexOf(Name);
  if Idx >= 0 then
  begin
    T := FTextures.Data[Idx];
    FRenderer.FreeTexture(T);
    FTextures.Delete(Idx);
    Exit;
  end;
  Idx := FFonts.IndexOf(Name);
  if Idx >= 0 then
  begin
    F := FFonts.Data[Idx];
    FRenderer.FreeFont(F);
    FFonts.Delete(Idx);
    Exit;
  end;
  Idx := FSounds.IndexOf(Name);
  if Idx >= 0 then
  begin
    S := FSounds.Data[Idx];
    FAudio.FreeSound(S);
    FSounds.Delete(Idx);
    Exit;
  end;
  Idx := FMusic.IndexOf(Name);
  if Idx >= 0 then
  begin
    M := FMusic.Data[Idx];
    FAudio.FreeMusic(M);
    FMusic.Delete(Idx);
  end;
end;

procedure TJREAssets.UnloadAll;
var
  I: Integer;
  T: TTexture;
  F: TFont;
  S: TSound;
  M: TMusic;
begin
  for I := 0 to FTextures.Count - 1 do
  begin
    T := FTextures.Data[I];
    FRenderer.FreeTexture(T);
  end;
  FTextures.Clear;

  for I := 0 to FFonts.Count - 1 do
  begin
    F := FFonts.Data[I];
    FRenderer.FreeFont(F);
  end;
  FFonts.Clear;

  for I := 0 to FSounds.Count - 1 do
  begin
    S := FSounds.Data[I];
    FAudio.FreeSound(S);
  end;
  FSounds.Clear;

  for I := 0 to FMusic.Count - 1 do
  begin
    M := FMusic.Data[I];
    FAudio.FreeMusic(M);
  end;
  FMusic.Clear;
end;

end.
