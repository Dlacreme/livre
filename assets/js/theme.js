export function applyTheme() {
  if (localStorage.theme === 'dark' || (!('theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
    document.documentElement.classList.add('dark')
    console.log(document.documentElement);
  } else {
    document.documentElement.classList.remove('dark')
  }
}

export function useTheme(theme) {
  if (theme != 'light' && theme != 'dark') {
    return;
  }
  localStorage.setItem('theme', theme)
  applyTheme()
}

export function detectTheme() {
  const theme = new URLSearchParams(window.location.search)
    .get('theme');
  if (theme) {
    useTheme(theme);
  } else {
    applyTheme();
  }
}