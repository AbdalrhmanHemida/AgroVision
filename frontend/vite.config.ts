import path from "path"
import react from "@vitejs/plugin-react"
import tailwindcss from "@tailwindcss/vite"
import { defineConfig, type PluginOption } from "vite"

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss() as PluginOption],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
})
