# JREP — Jolly Ratter Engine Pascal

A 2D game engine written in FreePascal, built on SDL2.

## Requirements

| Tool | Version |
|------|---------|
| Free Pascal Compiler | ≥ 3.2.0 |
| SDL2 | ≥ 2.0.10 |
| SDL2_image | any |
| SDL2_mixer | any |
| SDL2_ttf | any |

Install SDL2 on Debian/Ubuntu:
```bash
sudo apt install libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev
```

## Quick start

```bash
# Fetch SDL2 Pascal bindings
make vendor-get

# Build and run the hello example
make run-hello
```

## Project layout

```
src/
  jre.pas          Main engine unit — TJREEngine, TJREConfig
  jre_types.pas    TVector2, TRectF, TColor and constants
  jre_window.pas   SDL2 window wrapper
  jre_renderer.pas 2D renderer — textures, fonts, primitives
  jre_input.pas    Keyboard, mouse and scroll input
  jre_audio.pas    Sound effects and music (SDL_mixer)
  jre_assets.pas   Cached asset loader
  jre_entity.pas   Base TEntity class
  jre_scene.pas    Scene — owns and updates entity list
examples/
  hello/hello.pas  Bouncing coloured boxes demo
```

## Usage sketch

```pascal
program mygame;
{$mode objfpc}{$H+}
uses jre, jre_types, jre_entity, jre_renderer, SDL2;

type
  TPlayer = class(TEntity)
    procedure Update(DT: Single); override;
    procedure Render(R: TJRERenderer); override;
  end;

procedure TPlayer.Update(DT: Single);
begin
  // move, collide, etc.
end;

procedure TPlayer.Render(R: TJRERenderer);
begin
  R.FillRect(GetBounds, COLOR_GREEN);
end;

var Engine: TJREEngine;
begin
  Engine := TJREEngine.Create(JREConfig('My Game', 1280, 720));
  try
    Engine.Scene.Add(TPlayer.Create);
    Engine.Run;
  finally
    Engine.Free;
  end;
end.
```

## Makefile targets

| Target | Action |
|--------|--------|
| `make` | Build hello example |
| `make run-hello` | Build + run hello |
| `make vendor-get` | Clone SDL2-for-Pascal bindings |
| `make clean` | Remove build/ and bin/ |
