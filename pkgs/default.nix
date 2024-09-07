flakes: final: prev: with final; {
  mautrix-telegram = prev.mautrix-telegram.override { withE2BE = false; };
}
