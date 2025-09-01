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

export default function (eleventyConfig) {

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
    return collectionApi.getFilteredByGlob("src/articles/*.md");
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

  /**
   * Format dates in human-readable English format
   * Example: "August 29, 2025"
   */
  eleventyConfig.addFilter("formatDate", function (date) {
    if (!date) return '';
    const d = new Date(date);
    return d.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  });

  /**
   * Format dates to show only the year
   * Example: "2025"
   */
  eleventyConfig.addFilter("formatYear", function (date) {
    if (!date) return '';
    const d = new Date(date);
    return d.getFullYear().toString();
  });

  // ========================================
  // TAILWIND CSS INTEGRATION
  // ========================================

  /**
   * Build Tailwind CSS using the CLI
   * Processes input.css and generates output.css with all utilities
   */
  const buildTailwind = () => {
    try {
      console.log('🎨 Building Tailwind CSS...');
      execSync('bunx @tailwindcss/cli -i ./src/css/input.css -o ./src/css/output.css', {
        stdio: 'inherit',
        cwd: process.cwd()
      });
      console.log('✅ Tailwind CSS built successfully');
    } catch (error) {
      console.error('❌ Tailwind CSS build failed:', error.message);
    }
  };

  // Build CSS before Eleventy starts
  eleventyConfig.on('eleventy.before', buildTailwind);

  // Watch template files and CSS for changes
  eleventyConfig.addWatchTarget("src/**/*.{njk,md,html}");
  eleventyConfig.addWatchTarget("src/css/input.css");

  // Rebuild CSS when watched files change
  eleventyConfig.on('eleventy.beforeWatch', buildTailwind);

  // ========================================
  // FILE COPYING
  // ========================================

  // Copy compiled CSS to output directory
  eleventyConfig.addPassthroughCopy("src/css/output.css");

  // Copy Font Awesome font files for icon display
  eleventyConfig.addPassthroughCopy({
    "node_modules/@fortawesome/fontawesome-free/webfonts": "webfonts"
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
