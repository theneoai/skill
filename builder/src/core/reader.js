/**
 * Core Reader Module
 *
 * Reads companion Markdown files for the skill-writer-builder.
 * Sources: refs/, templates/, eval/, optimize/ (Single Source of Truth)
 */

const fs = require('fs-extra');
const path = require('path');
const { glob } = require('glob');

// Project root directory (reader is at builder/src/core/)
const PROJECT_ROOT = path.resolve(__dirname, '../../..');

/**
 * Parse a Markdown or JSON file
 * @param {string} filePath - Path to the file
 * @returns {Object} - Parsed content object
 */
async function parseFile(filePath) {
  const ext = path.extname(filePath).toLowerCase();
  const content = await fs.readFile(filePath, 'utf-8');

  if (ext === '.json') {
    return JSON.parse(content);
  }

  return {
    content,
    path: filePath,
    name: path.basename(filePath),
    extension: ext || '.md'
  };
}

/**
 * Read CREATE mode files from templates/
 * @returns {Object} - CREATE mode data
 */
async function readCreateMode() {
  const templatesDir = path.join(PROJECT_ROOT, 'templates');
  const data = {
    templates: {}
  };

  if (await fs.pathExists(templatesDir)) {
    const templateFiles = await glob('*.md', {
      cwd: templatesDir,
      absolute: true
    });

    for (const templatePath of templateFiles) {
      const templateName = path.basename(templatePath, '.md');
      // Skip the UTE snippet — it's not a skill template
      if (templateName === 'use-to-evolve-snippet') continue;
      data.templates[templateName] = await parseFile(templatePath);
    }
  }

  return data;
}

/**
 * Read EVALUATE mode files from eval/
 * @returns {Object} - EVALUATE mode data
 */
async function readEvaluateMode() {
  const evalDir = path.join(PROJECT_ROOT, 'eval');
  const data = {
    rubrics: null,
    benchmarks: null
  };

  const rubricsPath = path.join(evalDir, 'rubrics.md');
  if (await fs.pathExists(rubricsPath)) {
    data.rubrics = await parseFile(rubricsPath);
  }

  const benchmarksPath = path.join(evalDir, 'benchmarks.md');
  if (await fs.pathExists(benchmarksPath)) {
    data.benchmarks = await parseFile(benchmarksPath);
  }

  return data;
}

/**
 * Read OPTIMIZE mode files from optimize/ and refs/
 * @returns {Object} - OPTIMIZE mode data
 */
async function readOptimizeMode() {
  const optimizeDir = path.join(PROJECT_ROOT, 'optimize');
  const refsDir = path.join(PROJECT_ROOT, 'refs');
  const data = {
    strategies: null,
    antiPatterns: null,
    convergence: null
  };

  const strategiesPath = path.join(optimizeDir, 'strategies.md');
  if (await fs.pathExists(strategiesPath)) {
    data.strategies = await parseFile(strategiesPath);
  }

  const antiPatternsPath = path.join(optimizeDir, 'anti-patterns.md');
  if (await fs.pathExists(antiPatternsPath)) {
    data.antiPatterns = await parseFile(antiPatternsPath);
  }

  const convergencePath = path.join(refsDir, 'convergence.md');
  if (await fs.pathExists(convergencePath)) {
    data.convergence = await parseFile(convergencePath);
  }

  return data;
}

/**
 * Read shared resources (security patterns)
 * @returns {Object} - Shared resources data
 */
async function readSharedResources() {
  const refsDir = path.join(PROJECT_ROOT, 'refs');
  const data = {
    security: null
  };

  const securityPath = path.join(refsDir, 'security-patterns.md');
  if (await fs.pathExists(securityPath)) {
    data.security = await parseFile(securityPath);
  }

  return data;
}

/**
 * Read all data at once
 * @returns {Object} - Complete data for building
 */
async function readAllCoreData() {
  return {
    create: await readCreateMode(),
    evaluate: await readEvaluateMode(),
    optimize: await readOptimizeMode(),
    shared: await readSharedResources()
  };
}

module.exports = {
  readCreateMode,
  readEvaluateMode,
  readOptimizeMode,
  readSharedResources,
  readAllCoreData,
  parseFile,
  PROJECT_ROOT
};
