/**
 * Gemini Platform Adapter
 * 
 * Adapts skills to the Gemini platform format.
 * Gemini uses standard Markdown with YAML frontmatter, similar to OpenCode.
 */

const path = require('path');
const os = require('os');

const name = 'gemini';

const template = {
  frontmatter: `---
name: {{name}}
version: {{version}}
description: {{description}}
type: skill
author: {{author}}
tags: {{tags}}
---`,
  sections: [
    '## Overview',
    '## Usage',
    '## Examples'
  ],
  requiredFields: [
    'name',
    'version',
    'description'
  ]
};

/**
 * Format skill content for Gemini platform
 * @param {string} skillContent - Raw skill content
 * @returns {string} Formatted skill content
 */
function formatSkill(skillContent) {
  if (!skillContent || typeof skillContent !== 'string') {
    throw new Error('Invalid skill content provided');
  }

  let formatted = skillContent;

  // Ensure proper header hierarchy (Gemini prefers single H1)
  const h1Matches = formatted.match(/^#\s+.+$/gm);
  if (h1Matches && h1Matches.length > 1) {
    let count = 0;
    formatted = formatted.replace(/^#\s+(.+)$/gm, (match, title) => {
      count++;
      return count === 1 ? match : `## ${title}`;
    });
  }

  // Ensure proper formatting for Gemini
  // Gemini works well with standard Markdown
  return formatted.trim();
}

/**
 * Get the installation path for Gemini skills
 * @returns {string} Installation path
 */
function getInstallPath() {
  const homeDir = os.homedir();
  // Gemini doesn't have a standard local skill directory yet
  return path.join(homeDir, '.gemini', 'skills');
}

/**
 * Generate platform-specific metadata
 * @param {Object} skillData - Skill data object
 * @returns {Object} Platform metadata
 */
function generateMetadata(skillData) {
  return {
    platform: name,
    format: 'SKILL.md',
    version: skillData.version || '1.0.0',
    created: new Date().toISOString(),
    compatibility: {
      minVersion: '1.0.0',
      testedVersions: ['1.0.0']
    }
  };
}

/**
 * Validate skill structure for Gemini
 * @param {string} skillContent - Skill content to validate
 * @returns {Object} Validation result
 */
function validateSkill(skillContent) {
  const errors = [];
  const warnings = [];

  // Check YAML frontmatter
  const frontmatterMatch = skillContent.match(/^---\n([\s\S]*?)\n---/);
  if (!frontmatterMatch) {
    errors.push('Missing YAML frontmatter');
  } else {
    // Check required fields
    template.requiredFields.forEach(field => {
      const fieldPattern = new RegExp(`^${field}:`, 'm');
      if (!fieldPattern.test(frontmatterMatch[1])) {
        errors.push(`Missing required field: ${field}`);
      }
    });
  }

  // Check for single H1
  const h1Matches = skillContent.match(/^#\s+.+$/gm);
  if (h1Matches && h1Matches.length > 1) {
    warnings.push('Multiple H1 headers detected');
  }

  return {
    valid: errors.length === 0,
    errors,
    warnings
  };
}

module.exports = {
  name,
  template,
  formatSkill,
  getInstallPath,
  generateMetadata,
  validateSkill
};
