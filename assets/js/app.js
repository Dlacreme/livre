import "./_phoenix.js";
import { detectTheme } from "./theme.js";
import actions from "./actions.js";

detectTheme();

function loadLivre() {
  window.LIVRE = {
    actions: actions,
  }
}

addEventListener("DOMContentLoaded", (_ev) => loadLivre());