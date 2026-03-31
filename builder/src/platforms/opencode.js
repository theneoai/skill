/**
 * OpenCode Platform Adapter
 * 
 * Adapts skills to the OpenCode platform format.
 * OpenCode uses standard SKILL.md format with YAML frontmatter.
 */

const path = require('path');
const os = require('os');

const name = 'opencode';

const template = {
  frontmatter: `---
name: {{name}}
version: {{version}}
description: {{description}}
license: {{license}}
author: {{author}}
tags: {{tags}}
interface:
  mode:
    type: enum
    values: {{modes}}
    default: {{defaultMode}}
    description: Operating mode for the skill
---`,
  sections: [
    '## §1 Identity',
    '## §2 Mode Router',
    '## §3 Graceful Degradation',
    '## §4 Workflow',
    '## §5 Quality Gates',
    '## §6 Security Baseline',
    '## §7 Error Handling',
    '## §8 Usage Examples'
  ],
  requiredFields: [
    'name',
    'version',
    'description'
  ]
};

/**
 * Format skill content for OpenCode platform
 * @param {string} skillContent - Raw skill content
 * @returns {string} Formatted skill content
 */
function formatSkill(skillContent) {
  if (!skillContent || typeof skillContent !== 'string') {
    throw new Error('Invalid skill content provided');
  }

  // Validate YAML frontmatter presence
  const frontmatterMatch = skillContent.match(/^---\n([\s\S]*?)\n---/);
  if (!frontmatterMatch) {
    throw new Error('Skill content missing required YAML frontmatter');
  }

  // Ensure required sections are present
  const requiredSections = template.sections;
  const missingSections = requiredSections.filter(section => {
    const sectionPattern = new RegExp(`^${section.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}`, 'm');
    return !sectionPattern.test(skillContent);
  });

  if (missingSections.length > 0) {
    console.warn(`Warning: Missing recommended sections: ${missingSections.join(', ')}`);
  }

  // Ensure triggers are present at the end
  if (!skillContent.includes('**Triggers**:')) {
    skillContent += '\n\n---\n\n**Triggers**:\n';
  }

  return skillContent.trim();
}

/**
 * Get the installation path for OpenCode skills
 * @returns {string} Installation path
 */
function getInstallPath() {
  const homeDir = os.homedir();
  
  // Check for OpenCode config directory
  const opencodeDir = path.join(homeDir, '.config', 'opencode', 'skills');
  
  // Fallback to generic location if specific path not available
  return opencodeDir;
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
      testedVersions: ['1.0.0', '2.0.0']
    }
  };
}

/**
 * Validate skill structure for OpenCode
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

  // Check for required sections
  template.sections.forEach(section => {
    const sectionPattern = new RegExp(`^${section.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}`, 'm');
    if (!sectionPattern.test(skillContent)) {
      warnings.push(`Missing recommended section: ${section}`);
    }
  });

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
