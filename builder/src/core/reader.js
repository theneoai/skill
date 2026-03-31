/**
 * Core Reader Module
 * 
 * Reads and parses the core engine files for the skill-writer-builder.
 * Handles YAML and Markdown files, returning structured data objects.
 */

const fs = require('fs-extra');
const path = require('path');
const yaml = require('js-yaml');
const { glob } = require('glob');

// Core engine root directory (reader is at builder/src/core/, core is at ../../core/)
const CORE_DIR = path.resolve(__dirname, '../../../core');

/**
 * Parse a file based on its extension
 * @param {string} filePath - Path to the file
 * @returns {Object|string} - Parsed content or raw string
 */
async function parseFile(filePath) {
  const ext = path.extname(filePath).toLowerCase();
  const content = await fs.readFile(filePath, 'utf-8');

  switch (ext) {
    case '.yaml':
    case '.yml':
      return yaml.load(content);
    case '.json':
      return JSON.parse(content);
    case '.md':
    default:
      return {
        content,
        path: filePath,
        name: path.basename(filePath),
        extension: ext || '.md'
      };
  }
}

/**
 * Scan the core/ directory and return its structure
 * @returns {Object} - Directory structure with metadata
 */
async function readCoreStructure() {
  const structure = {
    root: CORE_DIR,
    modes: {},
    shared: null,
    metadata: {}
  };

  // Read main README
  const readmePath = path.join(CORE_DIR, 'README.md');
  if (await fs.pathExists(readmePath)) {
    structure.metadata = await parseFile(readmePath);
  }

  // Scan mode directories
  const modes = ['create', 'evaluate', 'optimize'];
  for (const mode of modes) {
    const modeDir = path.join(CORE_DIR, mode);
    if (await fs.pathExists(modeDir)) {
      const files = await glob('**/*', { 
        cwd: modeDir, 
        nodir: true,
        absolute: true 
      });
      
      structure.modes[mode] = {
        path: modeDir,
        files: files.map(f => path.relative(CORE_DIR, f)),
        hasReadme: files.some(f => f.endsWith('README.md'))
      };
    }
  }

  // Scan shared directory
  const sharedDir = path.join(CORE_DIR, 'shared');
  if (await fs.pathExists(sharedDir)) {
    const files = await glob('**/*', { 
      cwd: sharedDir, 
      nodir: true,
      absolute: true 
    });
    
    structure.shared = {
      path: sharedDir,
      files: files.map(f => path.relative(CORE_DIR, f))
    };
  }

  return structure;
}

/**
 * Read CREATE mode files
 * @returns {Object} - CREATE mode structured data
 */
async function readCreateMode() {
  const createDir = path.join(CORE_DIR, 'create');
  const data = {
    readme: null,
    workflow: null,
    elicitation: null,
    templates: {}
  };

  // Read README
  const readmePath = path.join(createDir, 'README.md');
  if (await fs.pathExists(readmePath)) {
    data.readme = await parseFile(readmePath);
  }

  // Read workflow
  const workflowPath = path.join(createDir, 'workflow.yaml');
  if (await fs.pathExists(workflowPath)) {
    data.workflow = await parseFile(workflowPath);
  }

  // Read elicitation
  const elicitationPath = path.join(createDir, 'elicitation.yaml');
  if (await fs.pathExists(elicitationPath)) {
    data.elicitation = await parseFile(elicitationPath);
  }

  // Read templates
  const templatesDir = path.join(createDir, 'templates');
  if (await fs.pathExists(templatesDir)) {
    const templateFiles = await glob('*.md', { 
      cwd: templatesDir, 
      absolute: true 
    });
    
    for (const templatePath of templateFiles) {
      const templateName = path.basename(templatePath, '.md');
      data.templates[templateName] = await parseFile(templatePath);
    }
  }

  return data;
}

/**
 * Read EVALUATE mode files
 * @returns {Object} - EVALUATE mode structured data
 */
async function readEvaluateMode() {
  const evaluateDir = path.join(CORE_DIR, 'evaluate');
  const data = {
    readme: null,
    phases: null,
    rubrics: null,
    certification: null
  };

  // Read README
  const readmePath = path.join(evaluateDir, 'README.md');
  if (await fs.pathExists(readmePath)) {
    data.readme = await parseFile(readmePath);
  }

  // Read phases
  const phasesPath = path.join(evaluateDir, 'phases.yaml');
  if (await fs.pathExists(phasesPath)) {
    data.phases = await parseFile(phasesPath);
  }

  // Read rubrics
  const rubricsPath = path.join(evaluateDir, 'rubrics.yaml');
  if (await fs.pathExists(rubricsPath)) {
    data.rubrics = await parseFile(rubricsPath);
  }

  // Read certification
  const certificationPath = path.join(evaluateDir, 'certification.yaml');
  if (await fs.pathExists(certificationPath)) {
    data.certification = await parseFile(certificationPath);
  }

  return data;
}

/**
 * Read OPTIMIZE mode files
 * @returns {Object} - OPTIMIZE mode structured data
 */
async function readOptimizeMode() {
  const optimizeDir = path.join(CORE_DIR, 'optimize');
  const data = {
    readme: null,
    strategies: null,
    dimensions: null,
    convergence: null
  };

  // Read README
  const readmePath = path.join(optimizeDir, 'README.md');
  if (await fs.pathExists(readmePath)) {
    data.readme = await parseFile(readmePath);
  }

  // Read strategies
  const strategiesPath = path.join(optimizeDir, 'strategies.yaml');
  if (await fs.pathExists(strategiesPath)) {
    data.strategies = await parseFile(strategiesPath);
  }

  // Read dimensions
  const dimensionsPath = path.join(optimizeDir, 'dimensions.yaml');
  if (await fs.pathExists(dimensionsPath)) {
    data.dimensions = await parseFile(dimensionsPath);
  }

  // Read convergence
  const convergencePath = path.join(optimizeDir, 'convergence.yaml');
  if (await fs.pathExists(convergencePath)) {
    data.convergence = await parseFile(convergencePath);
  }

  return data;
}

/**
 * Read shared resources (security patterns and helpers)
 * @returns {Object} - Shared resources structured data
 */
async function readSharedResources() {
  const sharedDir = path.join(CORE_DIR, 'shared');
  const data = {
    security: null,
    utils: null
  };

  // Read security patterns
  const securityPath = path.join(sharedDir, 'security', 'cwe-patterns.yaml');
  if (await fs.pathExists(securityPath)) {
    data.security = await parseFile(securityPath);
  }

  // Read utils/helpers
  const utilsPath = path.join(sharedDir, 'utils', 'helpers.yaml');
  if (await fs.pathExists(utilsPath)) {
    data.utils = await parseFile(utilsPath);
  }

  return data;
}

/**
 * Read all core data at once
 * @returns {Object} - Complete core engine data
 */
async function readAllCoreData() {
  return {
    structure: await readCoreStructure(),
    create: await readCreateMode(),
    evaluate: await readEvaluateMode(),
    optimize: await readOptimizeMode(),
    shared: await readSharedResources()
  };
}

module.exports = {
  readCoreStructure,
  readCreateMode,
  readEvaluateMode,
  readOptimizeMode,
  readSharedResources,
  readAllCoreData,
  parseFile,
  CORE_DIR
};
