import { applyTheme } from "./theme.js";

export default {
  toggleFloatingMenu: (_ev, targetId, arrowId) => {
    const target = document.getElementById(targetId);
    toggleClass(target, 'opacity-100');
    toggleClass(target, '-z-50');

    const arrow = document.getElementById(arrowId);
    toggleClass(arrow, 'rotate-180');
  },
  applyTheme: (ev) => {
    console.log('theme changed', ev);
    applyTheme('dark');
  }
}

function toggleClass(el, cls) {
  if (el) {
    if (el.classList.contains(cls)) {
      el.classList.remove(cls);
    } else {
      el.classList.add(cls);
    }
  }
}