/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: 'class',
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        brand: {
          lightgreen: '#E8F5E9',
          green: '#4CAF50',
          darkgreen: '#1B5E20',
          lightblue: '#E3F2FD',
          blue: '#2196F3',
          darkblue: '#0D47A1',
          charcoal: '#263238',
          softgray: '#F5F7FA'
        }
      },
      fontFamily: {
        rounded: ['"M PLUS Rounded 1c"', 'sans-serif'],
        sans: ['"Noto Sans SC"', '"Inter"', 'sans-serif']
      }
    }
  },
  plugins: []
};
