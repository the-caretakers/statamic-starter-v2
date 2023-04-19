module.exports = {
  content: [
    './resources/**/*.antlers.html',
    './resources/**/*.blade.php',
    './resources/**/*.{js,ts,jsx,tsx}',
    './content/**/*.md',
  ],
  theme: {
    container: {
        center: true,
        padding: "1.25rem",
    },
    fontFamily: {
        // Add your fonts here
        sans: ['Sharp Sans', 'Helvetica', 'arial', 'sans-serif'],
    },
    extend: {
        colors: {
            // Add your colors here
        },
        // Set default transition durations and easing when using the transition utilities.
        transitionDuration: {
            DEFAULT: '300ms',
        },
        transitionTimingFunction: {
            DEFAULT: 'cubic-bezier(0.4, 0, 0.2, 1)',
        },
    },
  },
  plugins: [
    require('@tailwindcss/typography'),
  ],
}
