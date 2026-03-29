#!/usr/bin/env bash
# file_utils.sh - 共享文件操作工具
#
# 提供跨平台的文件操作函数

# Guard against re-sourcing
if [[ -n "${_FILE_UTILS_SOURCED:-}" ]]; then
    return 0
fi
export _FILE_UTILS_SOURCED=1

sed_i() {
    if [[ "$(uname)" == "Darwin" ]]; then
        sed -i '' "$@"
    else
        sed -i "$@"
    fi
}

replace_section_content() {
    local skill_file="$1"
    local section_header="$2"
    local new_content="$3"
    
    if [[ ! -f "$skill_file" ]]; then
        echo "$new_content" > "$skill_file"
        return 0
    fi
    
    local section_pattern
    section_pattern=$(echo "$section_header" | sed 's/[][.*\/^$]/\\&/g')
    
    if grep -q "^## $section_pattern" "$skill_file"; then
        local start_line
        start_line=$(grep -n "^## $section_pattern" "$skill_file" | head -1 | cut -d: -f1)
        
        local end_line
        local remaining_lines
        remaining_lines=$(tail -n +$((start_line + 1)) "$skill_file" | grep -n "^## ")
        
        if [[ -n "$remaining_lines" ]]; then
            end_line=$(echo "$remaining_lines" | head -1 | cut -d: -f1)
            end_line=$((start_line + end_line - 1))
        else
            end_line=$(wc -l < "$skill_file")
        fi
        
        head -n $((start_line - 1)) "$skill_file" > "${skill_file}.tmp"
        echo "## $section_header" >> "${skill_file}.tmp"
        echo "" >> "${skill_file}.tmp"
        echo "$new_content" >> "${skill_file}.tmp"
        tail -n +$((end_line + 1)) "$skill_file" >> "${skill_file}.tmp" 2>/dev/null || true
        mv "${skill_file}.tmp" "$skill_file"
    else
        echo "" >> "$skill_file"
        echo "## $section_header" >> "$skill_file"
        echo "" >> "$skill_file"
        echo "$new_content" >> "$skill_file"
    fi
}
