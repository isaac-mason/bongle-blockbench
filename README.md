![Bongle Blockbench](cover.png)

# bongle-blockbench

A ready-to-go version of [Blockbench](https://www.blockbench.net/) for making
[Bongle](https://github.com/isaac-mason/bongle) characters and models. It is
plain Blockbench with a Bongle plugin added, so everything you already know about
Blockbench still works.

Two ways to use it:

- **Online:** open the hosted editor at `blockbench.bongle.io`. Nothing to install.
- **Desktop app:** add the Bongle plugin to the Blockbench desktop app (see
  [Install into the desktop app](#install-into-the-desktop-app)).

## Making a Bongle character

1. Choose **New > Bongle Character**. You start from the standard Bongle
   character, already rigged and textured, so you do not have to build the
   skeleton yourself.
2. Make it your own. Add and edit cubes and meshes on the existing bones (a hat
   on the head, armour on the body, and so on).
3. Watch the validator. Open the checklist icon to see if anything is wrong: a
   missing bone, or a bone in the wrong place. It also shows the exact bone
   layout a character needs.
4. Export. Choose **File > Export > Export Bongle glTF**. It checks the rig and
   saves a ready-to-use `.glb`.

Making something that is not a character (a prop, a creature, scenery)? Use
**New > Bongle Model** instead. It is the same idea without the character rig.

## Install into the desktop app

You do not need this for the online editor. To add Bongle to the Blockbench
desktop app:

1. In Blockbench: **File > Plugins > Load Plugin from URL**.
2. Paste this URL:
   `https://raw.githubusercontent.com/isaac-mason/bongle-blockbench/main/bongle.js`
3. Confirm. Blockbench remembers it and loads it every time you open the app.

To update later, load from the same URL again.

---

## Plugin Development

Stock Blockbench (a read-only submodule) plus the Bongle plugin, assembled into
a static site. The same plugin file also installs into the desktop app from its
raw URL.

### Layout

```
blockbench/        upstream Blockbench, pinned read-only submodule (v5.1.4)
plugin/src/        the bongle plugin source
starter/           New > Bongle Character template (embedded into bongle.js)
bongle.js          built, self-contained plugin (committed; raw-URL installable)
overlay/           branding assets layered onto the build (bongle.css, ...)
scripts/inject.mjs injects the plugin + branding into the built index.html
build.sh           bundles the plugin, builds Blockbench web, assembles dist/
```

`bongle.js` is generated from `plugin/src/` by `npm run build:plugin` (esbuild,
with `starter/character.bbmodel` inlined). It is committed so it can be loaded
into the desktop app from a raw URL. Rebuild and commit it when the source or
starter changes. The filename must stay `bongle.js`: Blockbench derives the
plugin id from it, and it must match `Plugin.register('bongle', ...)`.

The Blockbench submodule is treated as read-only. All integration happens in the
post-build assembly step, so updating Blockbench is a submodule bump, not a
merge. If a change ever needs upstream source edits, keep it as a `.patch` in a
`patches/` dir applied during the build rather than committing into the submodule.

### Build

```
git submodule update --init --recursive
npm install
npm run build:plugin   # -> bongle.js (also commit this)
npm run build          # -> dist/ (full hosted site)
npm run preview        # serve dist/ locally
```

`build.sh` runs `npm ci && npm run build-web` inside `blockbench/`, copies the
runtime tree into `dist/`, then injects `bongle.js` + `bongle.css`. `dist/` is a
static single-page app.

### What the plugin adds

- **Formats** `Bongle Character` (rigged) and `Bongle Model` (static), floated to
  the top of the New screen. New > Bongle Character opens the embedded starter.
- **Rig validation** against the engine's canonical 6-bone contract
  (`waist, body, head, arm_left, arm_right, leg_left, leg_right`), with optional
  sockets (`hand_left, hand_right, back`). It reports exactly what is wrong and
  prints the required hierarchy. Source of truth: engine `lib/src/core/avatar/rig.ts`
  and `lib/src/builtins/character.ts`.
- **Export Bongle glTF** with fixed options (no dialog), writing a tidy scene name
  into the `.glb`. The engine reads `.glb` (`lib/src/core/models/model-glb.ts`).
- **Branding** (additive, never removes Blockbench's own): a header badge and a
  start-screen card.

Licensed under GPL-3.0, matching Blockbench. See `blockbench/LICENSE.MD`.
