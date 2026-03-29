#!/usr/bin/env bash
# UNIFIED_SCORING.md - 统一评分系统
#
# 所有评分系统必须使用此常量文件确保一致性
#
# 评分系统: 1000分制 (兼容1155分实际得分)
#
# ============================================================================
# 评分维度 (与 eval/main.sh 保持一致)
# ============================================================================

# Phase 1: Parse & Validate
readonly PARSE_MAX=100

# Phase 2: Text Score  
readonly TEXT_MAX=505

# Phase 3: Runtime Score
readonly RUNTIME_MAX=450

# Phase 4: Certification
readonly CERTIFY_MAX=100

# 总分 (实际)
readonly TOTAL_ACTUAL_MAX=1155

# 显示总分 (归一化到1000)
readonly TOTAL_DISPLAY_MAX=1000

# ============================================================================
# 向后兼容: lean-orchestrator.sh 使用
# ============================================================================

# 使用 constants.sh 中定义的等级阈值
# PLATINUM_MIN, GOLD_MIN, SILVER_MIN, BRONZE_MIN from constants.sh

# lean-orchestrator 600分制 -> 1000分制转换系数
readonly LEAN_TO_STANDARD=1.667  # 600 * 1.667 ≈ 1000

# lean-orchestrator 等级阈值 (600分制)
# GOLD: 540 * 1.667 = 900 ✓
# SILVER: 480 * 1.667 = 800 ✓
# BRONZE: 420 * 1.667 = 700 ✓
readonly LEAN_TIER_GOLD=540
readonly LEAN_TIER_SILVER=480
readonly LEAN_TIER_BRONZE=420

# lean-orchestrator 等级阈值 (转换到1000分制后用于比较)
readonly LEAN_TIER_PLATINUM=950    # 570 * 1.667 ≈ 950 (matches 1000-point PLATINUM)
readonly LEAN_TIER_GOLD_NORM=900   # 540 * 1.667 ≈ 900 (matches constants.sh GOLD_MIN)
readonly LEAN_TIER_SILVER_NORM=800 # 480 * 1.667 ≈ 800 (matches constants.sh SILVER_MIN)
readonly LEAN_TIER_BRONZE_NORM=700 # 420 * 1.667 ≈ 700 (matches constants.sh BRONZE_MIN)

# ============================================================================
# 导出
# ============================================================================

export PARSE_MAX TEXT_MAX RUNTIME_MAX CERTIFY_MAX
export TOTAL_ACTUAL_MAX TOTAL_DISPLAY_MAX
export LEAN_TO_STANDARD LEAN_TIER_GOLD LEAN_TIER_SILVER LEAN_TIER_BRONZE
export LEAN_TIER_PLATINUM LEAN_TIER_GOLD_NORM LEAN_TIER_SILVER_NORM LEAN_TIER_BRONZE_NORM
