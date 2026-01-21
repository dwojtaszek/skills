#!/usr/bin/env python3
"""
Verification Partner - CLI Tool Wrapper

Executes Cursor Agent or GitHub Copilot CLI for independent verification.
Supports intelligent content splitting for large reviews.
"""

import argparse
import json
import subprocess
import sys
import shutil
import time
import re
import os
from concurrent.futures import ThreadPoolExecutor
from typing import List, Tuple, Optional


# ============================================================================
# MODEL CONFIGURATION
# ============================================================================

MODEL_CONFIG = {
    'cursor': {
        'default': 'gpt-5.2-codex-xhigh-fast',
        'available': ['gpt-5.2-codex-xhigh-fast', 'gpt-5.2-codex-xhigh', 'gemini-3-pro'],
    },
    'copilot': {
        'default': 'gemini-3-pro-preview',
        'available': ['gemini-3-pro-preview', 'gpt-5.1-codex-max'],
    }
}

# Intelligent model selection based on mode
MODE_MODEL_HINTS = {
    'code-review': 'openai',      # OpenAI models excel at code analysis
    'brainstorm': 'google',       # Google models good for creative thinking
    'doc-review': 'google',       # Google models good for language/docs
    'adr-review': 'openai',       # OpenAI for structured analysis
    'verify': 'openai',           # Default to OpenAI for general verification
}

DEFAULT_TIMEOUT = 180  # seconds (3 minutes max)
SIZE_WARNING_THRESHOLD = 100 * 1024  # 100KB
MAX_CHUNK_SIZE = 80 * 1024  # 80KB per chunk (leave room for prompt overhead)


# ============================================================================
# PROMPT TEMPLATES
# ============================================================================

PROMPT_TEMPLATES = {
    'brainstorm': '''Act as a technical brainstorming partner. I'm working on: {context}

Current idea/approach:
{content}

Please:
1. Evaluate this approach from different angles
2. Suggest 2-3 alternative approaches
3. Identify potential issues or edge cases
4. Recommend the most promising direction

Focus on practical, actionable alternatives.''',

    'code-review': '''Act as a senior code reviewer. Review the following code:

Context: {context}

```
{content}
```

Please analyze:
1. Code quality and best practices
2. Potential bugs or edge cases
3. Performance concerns
4. Security vulnerabilities
5. Maintainability and readability
6. Specific improvements with examples

Be thorough but focus on significant issues.''',

    'doc-review': '''Act as a technical documentation reviewer. Review this documentation:

Context: {context}

{content}

Please evaluate:
1. Completeness - Are there missing sections?
2. Clarity - Is it understandable for the target audience?
3. Accuracy - Any technical inaccuracies?
4. Structure - Is the organization logical?
5. Examples - Are there enough practical examples?
6. Specific improvements needed

Provide actionable feedback.''',

    'adr-review': '''Act as a senior software architect reviewing an ADR. Review this Architecture Decision Record:

Context: {context}

{content}

Evaluate:
1. Problem definition - Is the context clear?
2. Decision clarity - Is the decision well-articulated?
3. Alternatives - Are alternatives adequately considered?
4. Consequences - Are trade-offs properly analyzed?
5. Missing considerations - What's not addressed?
6. Recommendations for improvement

Follow ADR best practices (MADR format).''',

    'verify': '''Act as an independent technical advisor. I need verification on:

Context: {context}

{content}

Please provide:
1. Your independent analysis
2. Alternative perspectives to consider
3. Potential risks or issues
4. Recommendations

Be objective and thorough.''',

    # Template for chunked content
    'chunk_review': '''Act as a senior code reviewer. This is PART {chunk_num} of {total_chunks} of a larger review.

Context: {context}

Previous parts covered: {previous_summary}

Current section:
```
{content}
```

Please analyze this section for:
1. Code quality issues
2. Potential bugs
3. Security concerns
4. Performance issues

Note any issues that may relate to other parts of the codebase.'''
}


# ============================================================================
# CONTENT SPLITTING
# ============================================================================

def estimate_tokens(text: str) -> int:
    """Rough token estimation (~4 chars per token)"""
    return len(text) // 4


def split_by_files(content: str) -> List[Tuple[str, str]]:
    """Split content by file boundaries (### File: pattern)"""
    file_pattern = r'^### File: (.+)$'
    parts = re.split(file_pattern, content, flags=re.MULTILINE)

    if len(parts) <= 1:
        return [('single', content)]

    files = []
    # parts[0] is content before first file (usually empty)
    # parts[1], parts[2] = filename, content; parts[3], parts[4] = filename, content; etc.
    for i in range(1, len(parts), 2):
        if i + 1 < len(parts):
            filename = parts[i].strip()
            file_content = parts[i + 1].strip()
            files.append((filename, file_content))

    return files if files else [('single', content)]


def split_by_functions(content: str, language: str = None) -> List[Tuple[str, str]]:
    """Split content by function/class definitions"""
    # Patterns for common languages
    patterns = [
        r'^((?:async\s+)?(?:def|class)\s+\w+)',  # Python
        r'^((?:export\s+)?(?:async\s+)?(?:function|class|const\s+\w+\s*=\s*(?:async\s+)?(?:\([^)]*\)|[^=])\s*=>))',  # JS/TS
        r'^((?:pub\s+)?(?:fn|struct|impl|trait)\s+)',  # Rust
        r'^((?:public|private|protected)?\s*(?:static\s+)?(?:class|interface|func|function)\s+)',  # Go/Java/PHP
    ]

    combined_pattern = '|'.join(f'({p})' for p in patterns)

    # Find all function/class starts
    matches = list(re.finditer(combined_pattern, content, re.MULTILINE))

    if len(matches) <= 1:
        return [('section', content)]

    chunks = []
    for i, match in enumerate(matches):
        start = match.start()
        end = matches[i + 1].start() if i + 1 < len(matches) else len(content)
        chunk_content = content[start:end].strip()
        chunk_name = match.group(0).strip()[:50]  # First 50 chars as name
        chunks.append((chunk_name, chunk_content))

    # Include any content before first function
    if matches and matches[0].start() > 0:
        preamble = content[:matches[0].start()].strip()
        if preamble:
            chunks.insert(0, ('preamble', preamble))

    return chunks


def split_by_sections(content: str) -> List[Tuple[str, str]]:
    """Split by comment section markers"""
    section_patterns = [
        r'^[/#*-]{3,}\s*\n?\s*(.+?)\s*\n?\s*[/#*-]{3,}',  # === Section === or ### Section ###
        r'^(?://|#)\s*[-=]{5,}',  # // ----- or # =====
    ]

    combined = '|'.join(section_patterns)
    parts = re.split(combined, content, flags=re.MULTILINE)

    if len(parts) <= 1:
        return [('section', content)]

    chunks = []
    for i, part in enumerate(parts):
        if part and part.strip():
            name = f'section_{i}' if i % 2 == 0 else part.strip()[:30]
            chunks.append((name, part.strip()))

    return chunks


def intelligent_split(content: str, max_size: int = MAX_CHUNK_SIZE) -> List[dict]:
    """
    Intelligently split content for review, preserving logical boundaries.

    Strategy:
    1. Try splitting by file boundaries first
    2. If single file is too large, split by functions/classes
    3. If still too large, split by section markers
    4. Last resort: split by lines with overlap
    """
    content_size = len(content)

    if content_size <= max_size:
        return [{'name': 'full', 'content': content, 'chunk_num': 1, 'total': 1}]

    chunks = []

    # Strategy 1: Split by files
    files = split_by_files(content)

    for filename, file_content in files:
        if len(file_content) <= max_size:
            chunks.append({'name': filename, 'content': file_content})
        else:
            # Strategy 2: Split large file by functions
            functions = split_by_functions(file_content)

            current_chunk = []
            current_size = 0

            for func_name, func_content in functions:
                if current_size + len(func_content) > max_size and current_chunk:
                    # Save current chunk
                    combined = '\n\n'.join(c for _, c in current_chunk)
                    chunk_name = f"{filename}:{current_chunk[0][0]}"
                    chunks.append({'name': chunk_name, 'content': combined})
                    current_chunk = []
                    current_size = 0

                if len(func_content) > max_size:
                    # Strategy 3: Function too large, split by lines with context
                    lines = func_content.split('\n')
                    line_chunks = []
                    current_lines = []
                    current_len = 0

                    for line in lines:
                        if current_len + len(line) > max_size and current_lines:
                            line_chunks.append('\n'.join(current_lines))
                            # Keep last 5 lines as overlap context
                            current_lines = current_lines[-5:] if len(current_lines) > 5 else []
                            current_len = sum(len(l) for l in current_lines)
                        current_lines.append(line)
                        current_len += len(line)

                    if current_lines:
                        line_chunks.append('\n'.join(current_lines))

                    for i, lc in enumerate(line_chunks):
                        chunks.append({
                            'name': f"{filename}:{func_name}:part{i+1}",
                            'content': lc
                        })
                else:
                    current_chunk.append((func_name, func_content))
                    current_size += len(func_content)

            # Don't forget remaining chunk
            if current_chunk:
                combined = '\n\n'.join(c for _, c in current_chunk)
                chunk_name = f"{filename}:{current_chunk[0][0]}"
                chunks.append({'name': chunk_name, 'content': combined})

    # Number the chunks
    total = len(chunks)
    for i, chunk in enumerate(chunks):
        chunk['chunk_num'] = i + 1
        chunk['total'] = total

    return chunks


def warn_large_content(content: str) -> Optional[str]:
    """Generate warning message for large content"""
    size = len(content)
    if size > SIZE_WARNING_THRESHOLD:
        size_kb = size // 1024
        tokens = estimate_tokens(content)
        return f"Large content detected: {size_kb}KB (~{tokens:,} tokens). Content will be split for review."
    return None


# ============================================================================
# MODEL SELECTION
# ============================================================================

def select_model(tool: str, mode: str, user_model: str = None) -> str:
    """
    Select appropriate model based on tool, mode, and user preference.

    Priority:
    1. User-specified model (if valid)
    2. Intelligent selection based on mode
    3. Tool default
    """
    available = MODEL_CONFIG[tool]['available']
    default = MODEL_CONFIG[tool]['default']

    # User specified model
    if user_model:
        if user_model in available:
            return user_model
        # Check if it's a valid model for the other tool (common mistake)
        other_tool = 'copilot' if tool == 'cursor' else 'cursor'
        if user_model in MODEL_CONFIG[other_tool]['available']:
            print(f"Warning: {user_model} is not available for {tool}, using default", file=sys.stderr)
        return default

    # Intelligent selection based on mode
    hint = MODE_MODEL_HINTS.get(mode, 'openai')

    if hint == 'openai':
        # Prefer OpenAI-based models
        for model in available:
            if 'gpt' in model.lower() or 'codex' in model.lower():
                return model
    elif hint == 'google':
        # Prefer Google-based models
        for model in available:
            if 'gemini' in model.lower():
                return model

    return default


def validate_models() -> dict:
    """Validate that configured models are accessible"""
    validation = {'cursor': {}, 'copilot': {}}

    # We can't truly validate without making API calls
    # Just verify the config structure is correct
    for tool in ['cursor', 'copilot']:
        config = MODEL_CONFIG.get(tool, {})
        validation[tool] = {
            'configured': bool(config.get('available')),
            'default': config.get('default'),
            'available': config.get('available', []),
        }

    return validation


# ============================================================================
# VERIFICATION TOOLS
# ============================================================================

class VerificationTool:
    """Base class for verification tools"""

    def __init__(self, timeout=DEFAULT_TIMEOUT):
        self.timeout = timeout

    def is_available(self) -> bool:
        raise NotImplementedError

    def check_status(self) -> dict:
        raise NotImplementedError

    def execute(self, prompt: str, model: str = None) -> dict:
        raise NotImplementedError


class CursorAgent(VerificationTool):
    """Cursor Agent CLI wrapper"""

    def is_available(self) -> bool:
        return shutil.which('cursor') is not None

    def check_status(self) -> dict:
        try:
            result = subprocess.run(
                ['cursor', 'agent', 'status'],
                capture_output=True,
                text=True,
                timeout=5
            )
            return {
                'available': True,
                'connected': result.returncode == 0,
                'message': result.stdout.strip() if result.returncode == 0 else result.stderr.strip(),
                'models': MODEL_CONFIG['cursor']['available'],
                'default_model': MODEL_CONFIG['cursor']['default'],
            }
        except FileNotFoundError:
            return {'available': False, 'connected': False, 'message': 'cursor command not found'}
        except Exception as e:
            return {'available': False, 'connected': False, 'message': f'Status check failed: {str(e)}'}

    def execute(self, prompt: str, model: str = None) -> dict:
        model = model or MODEL_CONFIG['cursor']['default']
        start_time = time.time()

        try:
            process = subprocess.Popen(
                ['cursor', 'agent', '--model', model, '--print', '--output-format', 'text', prompt],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            stdout, stderr = process.communicate(timeout=self.timeout)
            elapsed = int(time.time() - start_time)

            return {
                'success': process.returncode == 0,
                'tool': 'Cursor',
                'model': model,
                'output': stdout.strip(),
                'error': stderr.strip() if process.returncode != 0 else None,
                'elapsed': f'{elapsed}s'
            }
        except subprocess.TimeoutExpired:
            process.terminate()
            try:
                stdout, stderr = process.communicate(timeout=2)
            except subprocess.TimeoutExpired:
                process.kill()
                stdout, stderr = process.communicate()
            return {
                'success': False,
                'tool': 'Cursor',
                'model': model,
                'output': stdout.strip() if stdout else None,
                'error': f'Timeout ({self.timeout}s)',
                'elapsed': f'{self.timeout}s'
            }
        except Exception as e:
            return {'success': False, 'tool': 'Cursor', 'model': model, 'output': None, 'error': str(e)}


class CopilotCLI(VerificationTool):
    """GitHub Copilot CLI wrapper"""

    def is_available(self) -> bool:
        return shutil.which('copilot') is not None

    def check_status(self) -> dict:
        try:
            result = subprocess.run(
                ['gh', 'auth', 'status'],
                capture_output=True,
                text=True,
                timeout=5
            )
            return {
                'available': True,
                'connected': 'Logged in' in result.stdout or result.returncode == 0,
                'message': result.stdout.strip(),
                'models': MODEL_CONFIG['copilot']['available'],
                'default_model': MODEL_CONFIG['copilot']['default'],
            }
        except FileNotFoundError:
            return {'available': False, 'connected': False, 'message': 'gh CLI not found'}
        except Exception as e:
            return {'available': False, 'connected': False, 'message': f'Status check failed: {str(e)}'}

    def execute(self, prompt: str, model: str = None, allow_tools: bool = False) -> dict:
        model = model or MODEL_CONFIG['copilot']['default']
        start_time = time.time()

        try:
            cmd = ['copilot', '--model', model, '-p', prompt]
            if allow_tools:
                cmd.insert(3, '--allow-all-tools')

            process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            stdout, stderr = process.communicate(timeout=self.timeout)
            elapsed = int(time.time() - start_time)

            return {
                'success': process.returncode == 0,
                'tool': 'Copilot',
                'model': model,
                'output': stdout.strip(),
                'error': stderr.strip() if process.returncode != 0 else None,
                'elapsed': f'{elapsed}s'
            }
        except subprocess.TimeoutExpired:
            process.terminate()
            try:
                stdout, stderr = process.communicate(timeout=2)
            except subprocess.TimeoutExpired:
                process.kill()
                stdout, stderr = process.communicate()
            return {
                'success': False,
                'tool': 'Copilot',
                'model': model,
                'output': stdout.strip() if stdout else None,
                'error': f'Timeout ({self.timeout}s)',
                'elapsed': f'{self.timeout}s'
            }
        except Exception as e:
            return {'success': False, 'tool': 'Copilot', 'model': model, 'output': None, 'error': str(e)}


# ============================================================================
# GIT HELPERS
# ============================================================================

def is_git_repo() -> bool:
    try:
        result = subprocess.run(
            ['git', 'rev-parse', '--is-inside-work-tree'],
            capture_output=True, text=True, timeout=5
        )
        return result.returncode == 0
    except Exception:
        return False


def get_git_diff(staged: bool = False, branch: str = None) -> str:
    try:
        if branch:
            cmd = ['git', 'diff', f'{branch}...HEAD']
        elif staged:
            cmd = ['git', 'diff', '--cached']
        else:
            cmd = ['git', 'diff']
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        return result.stdout.strip()
    except Exception as e:
        return f"Error getting git diff: {e}"


def get_git_files_changed(staged: bool = False, branch: str = None) -> list:
    try:
        if branch:
            cmd = ['git', 'diff', '--name-only', f'{branch}...HEAD']
        elif staged:
            cmd = ['git', 'diff', '--cached', '--name-only']
        else:
            cmd = ['git', 'diff', '--name-only']
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
        return [f.strip() for f in result.stdout.strip().split('\n') if f.strip()]
    except Exception:
        return []


def format_multi_file_content(files: list) -> str:
    content_parts = []
    for filepath in files:
        if os.path.exists(filepath):
            try:
                with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
                    file_content = f.read()
                ext = os.path.splitext(filepath)[1].lstrip('.')
                content_parts.append(f"### File: {filepath}\n```{ext}\n{file_content}\n```")
            except Exception as e:
                content_parts.append(f"### File: {filepath}\n[Error reading file: {e}]")
        else:
            content_parts.append(f"### File: {filepath}\n[File not found or deleted]")
    return '\n\n'.join(content_parts)


# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

def format_prompt(mode: str, context: str, content: str, chunk_info: dict = None) -> str:
    """Format prompt using template, with optional chunk information"""
    if chunk_info and chunk_info.get('total', 1) > 1:
        template = PROMPT_TEMPLATES['chunk_review']
        return template.format(
            context=context,
            content=content,
            chunk_num=chunk_info.get('chunk_num', 1),
            total_chunks=chunk_info.get('total', 1),
            previous_summary=chunk_info.get('previous_summary', 'None (this is the first part)')
        )

    template = PROMPT_TEMPLATES.get(mode, PROMPT_TEMPLATES['verify'])
    return template.format(context=context, content=content)


def run_verification(tool, prompt: str, model: str, allow_tools: bool = False):
    """Run verification on a single tool"""
    try:
        if isinstance(tool, CopilotCLI):
            return tool.execute(prompt, model, allow_tools)
        return tool.execute(prompt, model)
    except Exception as e:
        return {
            'success': False,
            'tool': tool.__class__.__name__,
            'model': model or 'unknown',
            'output': None,
            'error': str(e)
        }


def format_output(result: dict, mode: str, show_header: bool = True) -> str:
    lines = []
    if show_header:
        lines.append(f"## Independent Verification ({result['tool']} - {result['model']})")
        lines.append(f"\n**Mode**: {mode}")
        if result.get('elapsed'):
            lines.append(f" | **Elapsed**: {result['elapsed']}")
        lines.append("\n")
    if result['success']:
        lines.append(result['output'])
    else:
        lines.append(f"Error: {result['error']}")
    return '\n'.join(lines)


def format_comparison(results: list) -> str:
    if len(results) < 2:
        return ""
    successful = [r for r in results if r['success']]
    if len(successful) < 2:
        return ""
    lines = [
        "\n" + "="*80,
        "CROSS-VALIDATION SUMMARY",
        "="*80,
        f"\n**Tools Used**: {', '.join([r['tool'] for r in results])}",
        f"**Models Used**: {', '.join([r['model'] for r in results])}",
        f"**Success Rate**: {len(successful)}/{len(results)}",
    ]
    if all(r['success'] for r in results):
        lines.append("\nAll verifications completed successfully")
        lines.append("Compare perspectives above for comprehensive validation")
    else:
        lines.append("\nSome verifications failed - results may be incomplete")
    return '\n'.join(lines)


def format_chunked_results(all_results: list, mode: str) -> str:
    """Format results from multiple chunks"""
    lines = ["# Chunked Review Results\n"]

    for i, chunk_results in enumerate(all_results):
        lines.append(f"## Chunk {i+1}/{len(all_results)}\n")
        for result in chunk_results:
            lines.append(format_output(result, mode))
            lines.append("\n" + "-"*40 + "\n")

    # Summary
    total_results = sum(len(cr) for cr in all_results)
    successful = sum(1 for cr in all_results for r in cr if r['success'])
    lines.append(f"\n**Total chunks reviewed**: {len(all_results)}")
    lines.append(f"**Successful verifications**: {successful}/{total_results}")

    return '\n'.join(lines)


# ============================================================================
# MAIN
# ============================================================================

def main():
    parser = argparse.ArgumentParser(
        description='Verification Partner - Get second opinions from different AI models',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  %(prog)s --mode code-review --git-diff
  %(prog)s --mode code-review --git-staged
  %(prog)s --mode brainstorm --files design.md
  %(prog)s --check-status
        '''
    )

    parser.add_argument('--mode', default='verify',
                       choices=['brainstorm', 'code-review', 'doc-review', 'adr-review', 'verify'],
                       help='Verification mode (default: verify)')
    parser.add_argument('--context', help='Context for verification')
    parser.add_argument('--content', help='Content to verify (or pipe via stdin)')
    parser.add_argument('--tool', choices=['cursor', 'copilot', 'both'],
                       help='Which tool to use (default: both if available)')
    parser.add_argument('--model', help='Specify model (overrides intelligent selection)')
    parser.add_argument('--copilot-tools', action='store_true',
                       help='Enable Copilot tool execution (use with caution)')
    parser.add_argument('--json', action='store_true', help='Output as JSON')
    parser.add_argument('--check-status', action='store_true',
                       help='Check tool availability and auth status')
    parser.add_argument('--validate-models', action='store_true',
                       help='Validate model configuration')

    git_group = parser.add_argument_group('git options')
    git_group.add_argument('--git-diff', action='store_true', help='Review unstaged changes')
    git_group.add_argument('--git-staged', action='store_true', help='Review staged changes')
    git_group.add_argument('--git-branch', help='Review changes against branch')
    git_group.add_argument('--git-files', action='store_true', help='Include full file contents')
    git_group.add_argument('--files', nargs='+', help='Specific files to review')

    args = parser.parse_args()

    cursor = CursorAgent(timeout=DEFAULT_TIMEOUT)
    copilot = CopilotCLI(timeout=DEFAULT_TIMEOUT)

    # Handle status check
    if args.check_status:
        status = {
            'cursor': cursor.check_status() if cursor.is_available() else
                      {'available': False, 'connected': False, 'message': 'cursor command not found'},
            'copilot': copilot.check_status() if copilot.is_available() else
                       {'available': False, 'connected': False, 'message': 'copilot command not found'},
        }
        if args.json:
            print(json.dumps(status, indent=2))
        else:
            print("=== Verification Tools Status ===\n")
            for tool_name, tool_status in status.items():
                print(f"{tool_name.upper()}:")
                print(f"  Available: {'Yes' if tool_status['available'] else 'No'}")
                print(f"  Connected: {'Yes' if tool_status['connected'] else 'No'}")
                print(f"  Message: {tool_status['message']}")
                if tool_status.get('models'):
                    print(f"  Models: {', '.join(tool_status['models'])}")
                    print(f"  Default: {tool_status.get('default_model')}")
                print()
        sys.exit(0)

    # Handle model validation
    if args.validate_models:
        validation = validate_models()
        if args.json:
            print(json.dumps(validation, indent=2))
        else:
            print("=== Model Configuration ===\n")
            for tool, info in validation.items():
                print(f"{tool.upper()}:")
                print(f"  Configured: {'Yes' if info['configured'] else 'No'}")
                print(f"  Default: {info['default']}")
                print(f"  Available: {', '.join(info['available'])}")
                print()
        sys.exit(0)

    # Handle git integration
    git_mode = args.git_diff or args.git_staged or args.git_branch
    if git_mode:
        if not is_git_repo():
            parser.error("Not in a git repository")

        changed_files = get_git_files_changed(staged=args.git_staged, branch=args.git_branch)
        if not changed_files:
            print("No changes detected.", file=sys.stderr)
            sys.exit(0)

        if args.git_files:
            args.content = format_multi_file_content(changed_files)
        else:
            args.content = get_git_diff(staged=args.git_staged, branch=args.git_branch)

        if not args.context:
            file_list = ', '.join(changed_files[:5])
            if len(changed_files) > 5:
                file_list += f' (+{len(changed_files) - 5} more)'
            source = "staged" if args.git_staged else f"vs {args.git_branch}" if args.git_branch else "unstaged"
            args.context = f"Git {source}: {file_list}"

    elif args.files:
        args.content = format_multi_file_content(args.files)
        if not args.context:
            file_list = ', '.join(args.files[:5])
            if len(args.files) > 5:
                file_list += f' (+{len(args.files) - 5} more)'
            args.context = f"Review: {file_list}"

    # Read from stdin if needed
    if not args.content and not sys.stdin.isatty():
        args.content = sys.stdin.read()

    if not args.context or not args.content:
        parser.error("--context and --content required (or use --git-*/--files)")

    # Check for large content and split if needed
    warning = warn_large_content(args.content)
    if warning:
        print(f"Warning: {warning}", file=sys.stderr)

    chunks = intelligent_split(args.content)

    # Determine tools to use
    use_both = args.tool == 'both' or (args.tool is None and cursor.is_available() and copilot.is_available())
    use_cursor = args.tool == 'cursor' or (args.tool is None and cursor.is_available() and not copilot.is_available())
    use_copilot = args.tool == 'copilot' or (args.tool is None and copilot.is_available() and not cursor.is_available())

    # Select models intelligently
    cursor_model = select_model('cursor', args.mode, args.model) if (use_both or use_cursor) else None
    copilot_model = select_model('copilot', args.mode, args.model) if (use_both or use_copilot) else None

    all_chunk_results = []
    allow_tools = getattr(args, 'copilot_tools', False)

    # Process each chunk
    for chunk in chunks:
        chunk_info = {
            'chunk_num': chunk['chunk_num'],
            'total': chunk['total'],
            'previous_summary': f"Chunks 1-{chunk['chunk_num']-1}" if chunk['chunk_num'] > 1 else None
        }

        prompt = format_prompt(args.mode, args.context, chunk['content'],
                              chunk_info if chunk['total'] > 1 else None)

        results = []

        if use_both:
            with ThreadPoolExecutor(max_workers=2) as executor:
                futures = {}
                if cursor.is_available():
                    futures['cursor'] = executor.submit(run_verification, cursor, prompt, cursor_model, False)
                if copilot.is_available():
                    futures['copilot'] = executor.submit(run_verification, copilot, prompt, copilot_model, allow_tools)

                for tool_name in ['cursor', 'copilot']:
                    if tool_name in futures:
                        results.append(futures[tool_name].result())
        else:
            if use_cursor and cursor.is_available():
                results.append(cursor.execute(prompt, cursor_model))
            elif use_copilot and copilot.is_available():
                results.append(copilot.execute(prompt, copilot_model, allow_tools))

        all_chunk_results.append(results)

    if not all_chunk_results or not any(all_chunk_results):
        error_msg = "No verification tools available. Install Cursor CLI or GitHub Copilot CLI."
        if args.json:
            print(json.dumps({'success': False, 'error': error_msg}))
        else:
            print(f"Error: {error_msg}", file=sys.stderr)
        sys.exit(1)

    # Output results
    if args.json:
        output = {
            'chunks': len(chunks),
            'results': all_chunk_results,
            'models': {'cursor': cursor_model, 'copilot': copilot_model}
        }
        print(json.dumps(output, indent=2))
    else:
        if len(chunks) > 1:
            print(format_chunked_results(all_chunk_results, args.mode))
        else:
            results = all_chunk_results[0]
            for i, result in enumerate(results):
                if i > 0:
                    print(f"\n{'='*80}\n")
                print(format_output(result, args.mode))
            if len(results) > 1:
                print(format_comparison(results))

    # Exit with error if all failed
    if not any(r['success'] for chunk_results in all_chunk_results for r in chunk_results):
        sys.exit(1)


if __name__ == '__main__':
    main()
