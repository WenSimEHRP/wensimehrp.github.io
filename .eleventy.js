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
import markdownIt from 'markdown-it';
import markdownItFootnote from 'markdown-it-footnote';
import markdownItAnchor from 'markdown-it-anchor';
import markdownItAttrs from 'markdown-it-attrs';
import markdownItDeflist from 'markdown-it-deflist';
import TOML from '@iarna/toml';
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

  // ========================================
  // DATA FILE FORMATS
  // ========================================

  /**
   * Add TOML data file support
   */
  eleventyConfig.addDataExtension("toml", contents => TOML.parse(contents));

  // ========================================
  // MARKDOWN CONFIGURATION (GFM)
  // ========================================

  /**
   * Configure markdown-it with GitHub Flavored Markdown support
   */
  const markdownItOptions = {
    html: true,         // Enable HTML tags in source
    breaks: false,      // Convert '\n' in paragraphs into <br>
    linkify: true,      // Autoconvert URL-like text to links
    typographer: true   // Enable some language-neutral replacement + quotes beautification
  };

  const markdownLib = markdownIt(markdownItOptions)
    .use(markdownItFootnote)    // Footnotes support [^1]
    .use(markdownItAnchor, {    // Header anchors
      permalink: markdownItAnchor.permalink.linkInsideHeader({
        symbol: '<i class="fa-solid fa-link opacity-50 hover:opacity-100 transition-opacity" aria-hidden="true"></i>',
        placement: 'before',
        class: 'header-anchor'
      })
    })
    .use(markdownItAttrs)       // Add attributes to elements {.class #id}
    .use(markdownItDeflist);    // Definition lists

  // Set the markdown library
  eleventyConfig.setLibrary("md", markdownLib);

  // ========================================
  // COLLECTIONS
  // ========================================

  /**
   * Create a collection of articles from the articles directory
   */
  eleventyConfig.addCollection("articles", function (collectionApi) {
    return collectionApi.getFilteredByGlob("src/articles/*.{md,typ}");
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
  eleventyConfig.addWatchTarget("src/**/*.{njk,webc,md,html,typ}");
  eleventyConfig.addWatchTarget("src/css/input.css");

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
    "node_modules/@fontsource-variable/merriweather-sans/files/*": "css/files"
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
