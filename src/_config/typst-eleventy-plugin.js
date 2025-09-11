import { NodeCompiler } from '@myriaddreamin/typst-ts-node-compiler';

function isTypstDebug() {
  const d = process.env.DEBUG || '';
  return process.env.ELEVENTY_TYPST_DEBUG === '1' || d === 'typst' || d.includes('typst:') || d.split(',').some(s => s.trim() === 'typst');
}

async function htmlRender(compiler, inputArgs, inputPath) {
  let output = compiler.tryHtml({
    mainFilePath: inputPath,
    inputs: inputArgs
  });

  output.printDiagnostics();
  if (!output.result) {
    console.warn("[typst] Compilation failed, no HTML generated (non-fatal).", {
      file: inputPath
    });
    // Do not fail the Eleventy build; let the page render empty content
    // so the author can fix Typst errors manually.
    return "";
  }
  return output.result.body();
}

// Query frontmatter tag from Typst document, e.g. define in Typst:
// To ensure `#html` is available during query, we first compile with HTML target
// and then run the query against the compiled document.
async function getFrontmatter(compiler, inputPath) {
  try {
    const compiled = compiler.compileHtml({
      mainFilePath: inputPath,
      inputs: {},
    });
    // Print any diagnostics from the compile phase (warnings/errors)
    compiled.printDiagnostics();
    const doc = compiled.result;
    if (!doc) return null;
  const result = compiler.query(doc, { selector: '<frontmatter>' });
    // Optional debug log
    if (isTypstDebug()) {
  console.log('[typst] Frontmatter query ok:', Array.isArray(result) ? result.length : 0);
    }
    if (result && result.length > 0) return result[0].value;
  } catch (e) {
  console.warn('Typst frontmatter query failed:', e);
  }
  return null;
}

/**
 * Eleventy Plugin for Typst Integration (minimal)
 * Compiles .typ files to HTML only
 */
export default function typstEleventyPlugin(eleventyConfig, options = {}) {
  const { workspace = "." } = options;

  const compiler = NodeCompiler.create({
    workspace,
    features: ["html"] // enable html feature for documents using #html
  });

  // Register the .typ extension
  eleventyConfig.addExtension("typ", {
  // Provide layout/title from Typst <frontmatter> tag (no default layout)
    getData: async function (inputPath) {
      let fm = await getFrontmatter(compiler, inputPath);

      const fmAll = (fm && typeof fm === 'object') ? fm : {};
      return {
  // Expose everything from Typst frontmatter at top-level
        ...fmAll,
      };
    },
    compile: function (contents, inputPath) {
      return async (data) => {
  const inputArgs = {
          url: data?.metadata?.url,
          date: data?.page?.date?.toISOString?.(),
          source: data?.page?.inputPath,
          fileSlug: data?.page?.fileSlug,
        };
  return htmlRender(compiler, inputArgs, inputPath);
      };
    },
    read: false,
    outputFileExtension: "html"
  });
}
