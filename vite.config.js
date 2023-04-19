import laravel from 'laravel-vite-plugin';
import { defineConfig, loadEnv } from 'vite';

export default defineConfig(({ command, mode }) => {
    const env = loadEnv(mode, process.cwd(), '')
    return {
        plugins: [
            laravel([
                'resources/js/app.js',
            ])
        ],
        server: {
            open: env.APP_URL
        }
    }
});
