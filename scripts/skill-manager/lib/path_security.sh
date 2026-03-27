#!/usr/bin/env bash
# path_security.sh — 路径安全验证 (CWE-22 防护)
# 版本: 1.0.0
# 解决: 路径遍历风险
#
# 用法: source path_security.sh

# ═══════════════════════════════════════════════════════════════════════════════
# 配置
# ═══════════════════════════════════════════════════════════════════════════════

readonly DEFAULT_ALLOWED_DIRS="${SKILL_BASE_DIR:-$(pwd)}"

# ═══════════════════════════════════════════════════════════════════════════════
# 核心函数
# ═══════════════════════════════════════════════════════════════════════════════

# 验证路径是否在允许目录内
# 用法: validated=$(validate_path "$input_path") || exit 1
validate_path() {
    local input_path="$1"
    
    # 获取真实路径
    local real_path
    real_path=$(realpath "$input_path" 2>/dev/null) || {
        echo "Error: Cannot resolve path: $input_path" >&2
        return 1
    }
    
    # 检查是否为绝对路径
    if [[ "$real_path" != /* ]]; then
        echo "Error: Path must be absolute: $input_path" >&2
        return 1
    fi
    
    # 检查允许目录
    local allowed_dirs="${ALLOWED_SKILL_DIRS:-$DEFAULT_ALLOWED_DIRS}"
    local allowed=false
    
    IFS=':' read -ra dirs <<< "$allowed_dirs"
    for dir in "${dirs[@]}"; do
        [[ -z "$dir" ]] && continue
        
        local real_dir
        real_dir=$(realpath "$dir" 2>/dev/null) || continue
        
        if [[ "$real_path" == "$real_dir"/* ]]; then
            allowed=true
            break
        fi
    done
    
    if [[ "$allowed" == false ]]; then
        echo "Error: Path outside allowed directories: $input_path" >&2
        echo "  Allowed: $allowed_dirs" >&2
        echo "  Set SKILL_BASE_DIR environment variable to configure" >&2
        return 1
    fi
    
    echo "$real_path"
}

# 验证文件是否存在且可读
# 用法: validate_file "$file_path" || exit 1
validate_file() {
    local file_path
    file_path=$(validate_path "$1") || return 1
    
    if [[ ! -f "$file_path" ]]; then
        echo "Error: Not a file: $file_path" >&2
        return 1
    fi
    
    if [[ ! -r "$file_path" ]]; then
        echo "Error: File not readable: $file_path" >&2
        return 1
    fi
    
    echo "$file_path"
}

# 验证目录是否存在且可读
# 用法: validate_dir "$dir_path" || exit 1
validate_dir() {
    local dir_path
    dir_path=$(validate_path "$1") || return 1
    
    if [[ ! -d "$dir_path" ]]; then
        echo "Error: Not a directory: $dir_path" >&2
        return 1
    fi
    
    if [[ ! -r "$dir_path" ]]; then
        echo "Error: Directory not readable: $dir_path" >&2
        return 1
    fi
    
    echo "$dir_path"
}

# 检查路径遍历攻击 (CWE-22)
# 用法: if contains_path_traversal "$input"; then echo "HACK!"; fi
contains_path_traversal() {
    local input="$1"
    [[ "$input" == *".."* ]] || [[ "$input" == *"/.."* ]] || [[ "$input" == *"../"* ]]
}

# 获取安全的文件名 (移除路径遍历尝试)
# 用法: safe_name=$(sanitize_filename "$user_input")
sanitize_filename() {
    local input="$1"
    # 移除 .. 和连续斜杠
    echo "$input" | sed 's/\.\.//g' | sed 's/\/\+/\//g' | xargs basename 2>/dev/null || echo "$input"
}

# ═══════════════════════════════════════════════════════════════════════════════
# 导出函数供其他脚本使用
# ═══════════════════════════════════════════════════════════════════════════════

export -f validate_path validate_file validate_dir contains_path_traversal sanitize_filename
