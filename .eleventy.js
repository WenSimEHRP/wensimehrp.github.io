/**
 * Eleventy Configuration File
 *
 * This file configures the Eleventy static site generator with:
 * - Custom filters for date handling
 * - GitHub Flavored Markdown (GFM) support
 * - Tailwind CSS integration
 * - Font Awesome font copying
 * - File watching and hot reload
 * - TOML data file support
 */

import { execSync } from 'child_process';
import pluginWebc from '@11ty/eleventy-plugin-webc';
import { minify as htmlMinify } from 'html-minifier-terser';
import typstEleventyPlugin from './src/_config/typst-eleventy-plugin.js';

export default function (eleventyConfig) {

  // ========================================
  // SETTINGS & CONSTANTS
  // ========================================

  const isProd = process.env.NODE_ENV === 'production';

  // ========================================
  // WEBC PLUGIN
  // ========================================

  /**
   * Add WebC support for single file web components
   */
  eleventyConfig.addPlugin(pluginWebc, {
    // Global components available everywhere
    components: "src/_includes/components/**/*.webc"
  });

  // ========================================
  // TYPST PLUGIN
  // ========================================

  // Enable Typst (.typ) files to compile to HTML via our custom plugin
  eleventyConfig.addPlugin(typstEleventyPlugin, { workspace: "." });
  // Ensure Eleventy treats .typ as a template format
  eleventyConfig.addTemplateFormats("typ");

  // (TOML data extension removed per user request)

  // ========================================
  // COLLECTIONS
  // ========================================

  /**
   * Create a collection of articles from the articles directory
   */
  eleventyConfig.addCollection("articles", function (collectionApi) {
    return collectionApi.getFilteredByGlob("src/articles/*.typ");
  });

  // ========================================
  // CUSTOM FILTERS
  // ========================================

  /**
   * Get the last modification date of a file from Git history
   * Falls back to current date if Git info is unavailable
   */
  eleventyConfig.addFilter("lastModified", function (inputPath) {
    try {
      const result = execSync(`git log -1 --format=%ci "${inputPath}"`, { encoding: 'utf8' });
      return new Date(result.trim());
    } catch (error) {
      console.warn(`Could not get git info for ${inputPath}:`, error.message);
      return new Date(); // Fallback to current date
    }
  });

  // DRY date formatting helper
  const formatDate = (date, opts) => {
    if (!date) return '';
    const d = new Date(date);
    return d.toLocaleDateString('en-US', opts);
  };

  eleventyConfig.addFilter("formatDate", (date) =>
    formatDate(date, { year: 'numeric', month: 'long', day: 'numeric' })
  );

  eleventyConfig.addFilter("formatDateShort", (date) =>
    formatDate(date, { year: 'numeric', month: 'short', day: 'numeric' })
  );

  eleventyConfig.addFilter("formatYear", (date) => {
    if (!date) return '';
    const d = new Date(date);
    return d.getFullYear().toString();
  });

  // ========================================
  // BUILD TASKS
  // ========================================

  // Unified command runner to reduce duplicated execSync code
  const run = (startLabel, command) => {
    try {
      console.log(startLabel);
      execSync(command, { stdio: 'inherit', cwd: process.cwd() });
      console.log('✅ Done');
    } catch (error) {
      console.error('❌ Failed:', error.message);
    }
  };

  /** Build Tailwind CSS using the CLI */
  const buildTailwind = () => run('🎨 Building Tailwind CSS...', 'bunx @tailwindcss/cli -i ./src/css/input.css -o ./src/css/output.css');

  /** Build Pagefind indices using the CLI */
  const buildPagefind = () => run('🔍 Building Pagefind indices...', 'bunx pagefind --site dist');

  // BUILD HOOKS & WATCHERS
  // ========================================

  // Build CSS before Eleventy starts
  eleventyConfig.on('eleventy.before', buildTailwind);
  // Build Pagefind indices after Eleventy finishes
  eleventyConfig.on('eleventy.after', buildPagefind);

  // Watch template files and CSS for changes
  eleventyConfig.addWatchTarget("src");
  // Watch the Typst library for changes
  eleventyConfig.addWatchTarget("wslib");

  // Rebuild CSS when watched files change
  eleventyConfig.on('eleventy.beforeWatch', buildTailwind);

  // ========================================
  // OUTPUT TRANSFORMS
  // ========================================

  // ========================================
  // HTML MINIFICATION
  // ========================================

  /**
   * Minify final HTML output using html-minifier-terser
   * Runs for all generated .html files
   */
  eleventyConfig.addTransform('htmlmin', async (content, outputPath) => {
    if (outputPath && outputPath.endsWith('.html')) {
      try {
        const beforeLen = content.length;
        const result = await htmlMinify(content, {
          collapseWhitespace: true,
          removeComments: true,
          minifyCSS: true,
          minifyJS: true,
          useShortDoctype: true,
          keepClosingSlash: true,
          removeRedundantAttributes: true,
          removeEmptyAttributes: true
        });
  const afterLen = result.length;
  const saved = Math.max(0, beforeLen - afterLen);
  const savedKiB = (saved / 1024).toFixed(2);
  const pct = beforeLen ? ((saved / beforeLen) * 100).toFixed(1) : '0.0';
  console.log(`✅ HTML minified: -${savedKiB} KiB (${pct}%) ${outputPath}`);
        return result;
      } catch (error) {
        console.error(`❌ HTML minification failed for ${outputPath}:`, error.message);
        return content; // Fallback: return unminified content
      }
    }
    return content;
  });

  // ========================================
  // ASSETS PASS-THROUGH
  // ========================================

  // Copy compiled CSS to output directory
  eleventyConfig.addPassthroughCopy("src/css/output.css");

  // Copy Font Awesome font files for icon display
  eleventyConfig.addPassthroughCopy({
    "node_modules/@fortawesome/fontawesome-free/webfonts": "webfonts"
  });

  // Copy Merriweather Sans font files from node_modules to output
  eleventyConfig.addPassthroughCopy({
    "node_modules/@fontsource-variable/merriweather-sans/files/merriweather-sans-latin-wght-normal.woff2": "webfonts/merriweather-sans-latin-wght-normal.woff2",
    "node_modules/@fontsource-variable/merriweather-sans/files/merriweather-sans-latin-wght-italic.woff2": "webfonts/merriweather-sans-latin-wght-italic.woff2"
  });

  // ========================================
  // ELEVENTY CONFIGURATION
  // ========================================

  return {
    dir: {
      input: "src",      // Source files directory
      output: "dist"     // Built site output directory
    }
  };
}
