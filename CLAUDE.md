# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Claude Code is an agentic coding tool that operates as a CLI application for helping developers with coding tasks through natural language commands. This repository contains the main Claude Code project files, documentation, configuration, and examples.

## Architecture

- **Main Repository Structure**: This is primarily a documentation and distribution repository for Claude Code (not a traditional codebase with source code)
- **Binary Distribution**: Claude Code itself is distributed as an npm package (`@anthropic-ai/claude-code`) - this repo contains configuration, examples, and documentation
- **Configuration**: User configuration and custom commands are stored in `.claude/` directory with tool restrictions defined in command YAML frontmatter
- **Examples**: Sample hooks and integrations are provided in `examples/` directory
- **Development Environment**: DevContainer setup with network isolation and firewall configuration for secure development

## Development Environment

### DevContainer Setup
- Use the provided DevContainer configuration in `.devcontainer/` for consistent development environment
- Run the PowerShell script for Windows DevContainer setup: `.\Script\run_devcontainer_claude_code.ps1 -Backend docker` or `-Backend podman`
- DevContainer includes Claude Code extension, ESLint, Prettier, and GitLens

### Network Security
- DevContainer includes comprehensive firewall configuration (`init-firewall.sh`) that restricts outbound connections to only:
  - GitHub (API, web, git)
  - NPM registry
  - Anthropic API endpoints
  - Sentry and Statsig (analytics)
  - VS Code marketplace and update servers
  - DNS and SSH
- Firewall uses iptables and ipset with dynamic IP range updates

### Installation and Usage
```bash
# Install globally
npm install -g @anthropic-ai/claude-code

# Navigate to project directory and run
claude
```

## Custom Commands

The repository includes pre-built custom commands in `.claude/commands/`:

### commit-push-pr
- **Purpose**: Streamlined workflow to commit changes, push to origin, and create pull request
- **Tools**: Limited to git and GitHub CLI operations via YAML frontmatter restrictions
- **Process**: Creates branch if on main → commits → pushes → creates PR
- **Usage**: Automatically handles the complete git workflow in a single command

### dedupe
- **Purpose**: Find and flag duplicate GitHub issues
- **Tools**: Limited to GitHub CLI operations only via YAML frontmatter restrictions
- **Process**: Multi-agent workflow to analyze issues and search for duplicates
- **Features**: Auto-closure warning system with 3-day grace period

## GitHub Integration

### GitHub Actions
- **claude.yml**: Responds to @claude mentions in issues, PRs, and comments using the Claude Code action
- **Issue Triage**: Automated workflow for triaging GitHub issues
- **Issue Templates**: Configured templates for bugs, features, documentation, and model behavior reports

### Command Structure
- Commands use YAML frontmatter with `allowed-tools` to restrict available tools
- `description` field provides context for the command's purpose
- Commands are executed with specific tool permissions for security

## Hook System

### Example Hook: Bash Command Validator
- **Location**: `examples/hooks/bash_command_validator_example.py`
- **Purpose**: PreToolUse hook that validates bash commands before execution
- **Rules**:
  - Suggests `rg` (ripgrep) instead of `grep`
  - Recommends `rg --files` patterns instead of `find -name`
- **Configuration**: Requires path configuration in Claude settings and runs as a PreToolUse hook

## Development Guidelines

### Command Development
- Custom commands should use YAML frontmatter for tool restrictions
- Include clear descriptions and allowed tools for security
- Commands should be focused on specific workflows

### Security Considerations
- DevContainer environment includes network isolation
- Commands have tool restrictions to prevent unauthorized operations
- Firewall configuration limits outbound connections to approved domains

### File Organization
- Keep documentation focused on Claude Code usage and integration
- Custom commands should be well-documented with clear tool restrictions
- Examples should include complete configuration instructions

## Recommended VS Code Extensions
- **anthropic.claude-code**: Claude Code integration
- **dbaeumer.vscode-eslint**: JavaScript/TypeScript linting
- **esbenp.prettier-vscode**: Code formatting
- **eamodio.gitlens**: Git integration and visualization
- **ms-vscode-remote.remote-containers**: DevContainer support

## Support and Reporting
- Use `/bug` command within Claude Code for issue reporting
- GitHub issues: https://github.com/anthropics/claude-code/issues
- Discord community: Claude Developers Discord