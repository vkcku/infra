#!/usr/bin/env nu

nix flake update pastyears
git add flake.lock
git commit -m "pastyears: update pastyears" -- flake.lock
