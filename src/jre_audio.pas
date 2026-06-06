unit jre_audio;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, SDL2_mixer;

type
  TSound = record
    Handle: PMix_Chunk;
  end;

  TMusic = record
    Handle: PMix_Music;
  end;

  TJREAudio = class
  private
    FMasterVolume: Single;
    FMusicVolume:  Single;
    FSoundVolume:  Single;
    procedure ApplyVolumes;
  public
    constructor Create(Frequency: Integer = MIX_DEFAULT_FREQUENCY;
      Channels: Integer = 2; ChunkSize: Integer = 2048);
    destructor Destroy; override;

    function  LoadSound(const Path: string): TSound;
    procedure FreeSound(var S: TSound);
    procedure PlaySound(const S: TSound; Loops: Integer = 0; Channel: Integer = -1);
    procedure StopChannel(Channel: Integer = -1);

    function  LoadMusic(const Path: string): TMusic;
    procedure FreeMusic(var M: TMusic);
    procedure PlayMusic(const M: TMusic; Loops: Integer = -1);
    procedure StopMusic;
    procedure PauseMusic;
    procedure ResumeMusic;
    function  IsMusicPlaying: Boolean;

    procedure SetMasterVolume(Value: Single);
    procedure SetMusicVolume(Value: Single);
    procedure SetSoundVolume(Value: Single);
    property MasterVolume: Single read FMasterVolume;
    property MusicVolume:  Single read FMusicVolume;
    property SoundVolume:  Single read FSoundVolume;
  end;

implementation

constructor TJREAudio.Create(Frequency, Channels, ChunkSize: Integer);
begin
  if Mix_OpenAudio(Frequency, MIX_DEFAULT_FORMAT, Channels, ChunkSize) < 0 then
    raise Exception.CreateFmt('SDL_mixer init failed: %s', [Mix_GetError()]);
  Mix_AllocateChannels(32);
  FMasterVolume := 1.0;
  FMusicVolume  := 1.0;
  FSoundVolume  := 1.0;
  ApplyVolumes;
end;

destructor TJREAudio.Destroy;
begin
  Mix_CloseAudio;
  inherited;
end;

procedure TJREAudio.ApplyVolumes;
begin
  Mix_VolumeMusic(Round(FMasterVolume * FMusicVolume * MIX_MAX_VOLUME));
  Mix_Volume(-1,   Round(FMasterVolume * FSoundVolume * MIX_MAX_VOLUME));
end;

function TJREAudio.LoadSound(const Path: string): TSound;
begin
  Result.Handle := Mix_LoadWAV(PAnsiChar(AnsiString(Path)));
  if Result.Handle = nil then
    raise Exception.CreateFmt('Failed to load sound "%s": %s',
      [Path, Mix_GetError()]);
end;

procedure TJREAudio.FreeSound(var S: TSound);
begin
  if S.Handle <> nil then
  begin
    Mix_FreeChunk(S.Handle);
    S.Handle := nil;
  end;
end;

procedure TJREAudio.PlaySound(const S: TSound; Loops, Channel: Integer);
begin
  Mix_PlayChannel(Channel, S.Handle, Loops);
end;

procedure TJREAudio.StopChannel(Channel: Integer);
begin
  Mix_HaltChannel(Channel);
end;

function TJREAudio.LoadMusic(const Path: string): TMusic;
begin
  Result.Handle := Mix_LoadMUS(PAnsiChar(AnsiString(Path)));
  if Result.Handle = nil then
    raise Exception.CreateFmt('Failed to load music "%s": %s',
      [Path, Mix_GetError()]);
end;

procedure TJREAudio.FreeMusic(var M: TMusic);
begin
  if M.Handle <> nil then
  begin
    Mix_FreeMusic(M.Handle);
    M.Handle := nil;
  end;
end;

procedure TJREAudio.PlayMusic(const M: TMusic; Loops: Integer);
begin
  Mix_PlayMusic(M.Handle, Loops);
end;

procedure TJREAudio.StopMusic;
begin
  Mix_HaltMusic;
end;

procedure TJREAudio.PauseMusic;
begin
  Mix_PauseMusic;
end;

procedure TJREAudio.ResumeMusic;
begin
  Mix_ResumeMusic;
end;

function TJREAudio.IsMusicPlaying: Boolean;
begin
  Result := Mix_PlayingMusic <> 0;
end;

procedure TJREAudio.SetMasterVolume(Value: Single);
begin
  FMasterVolume := Clamp(Value, 0, 1);
  ApplyVolumes;
end;

procedure TJREAudio.SetMusicVolume(Value: Single);
begin
  FMusicVolume := Clamp(Value, 0, 1);
  ApplyVolumes;
end;

procedure TJREAudio.SetSoundVolume(Value: Single);
begin
  FSoundVolume := Clamp(Value, 0, 1);
  ApplyVolumes;
end;

function Clamp(V, Lo, Hi: Single): Single;
begin
  if V < Lo then Result := Lo
  else if V > Hi then Result := Hi
  else Result := V;
end;

end.
